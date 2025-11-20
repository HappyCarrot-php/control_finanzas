import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class BackupService {
  static final BackupService instance = BackupService._init();
  BackupService._init();

  // Obtener directorio de backups
  Future<Directory> getBackupsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(path.join(directory.path, 'WealthVault_Backups'));
    
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }
    
    return backupsDir;
  }

  // Exportar base de datos a un archivo (copia binaria)
  Future<String> exportDatabase() async {
    try {
      // Obtener la base de datos actual
      final db = await DatabaseHelper.instance.database;
      final dbPath = db.path;
      
      // Obtener directorio de backups
      final backupsDir = await getBackupsDirectory();
      
      // Crear nombre de archivo con timestamp
      final now = DateTime.now();
      final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_'
                       '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}';
      final backupFileName = 'control_finanzas_backup_$timestamp.db';
      final backupPath = path.join(backupsDir.path, backupFileName);
      
      // Copiar archivo de base de datos
      final dbFile = File(dbPath);
      if (!await dbFile.exists()) {
        throw Exception('El archivo de base de datos no existe');
      }
      
      final backupFile = await dbFile.copy(backupPath);
      
      // Verificar que el backup se creó correctamente
      if (await backupFile.exists()) {
        return backupPath;
      } else {
        throw Exception('No se pudo crear el archivo de backup');
      }
    } catch (e) {
      throw Exception('Error al exportar base de datos: $e');
    }
  }

  // Exportar base de datos como SQL a carpeta seleccionada por el usuario
  Future<String?> exportDatabaseAsSQL({String? customPath}) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Crear nombre de archivo con timestamp
      final now = DateTime.now();
      final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
                       '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final backupFileName = 'control_finanzas_$timestamp.sql';
      
      String? selectedDirectory;
      if (customPath != null) {
        selectedDirectory = customPath;
      } else {
        // Permitir al usuario seleccionar carpeta
        selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Selecciona dónde guardar el backup',
        );
      }
      
      if (selectedDirectory == null) {
        return null; // Usuario canceló
      }
      
      final backupPath = path.join(selectedDirectory, backupFileName);
      final file = File(backupPath);
      
      // Generar SQL completo
      final sqlContent = StringBuffer();
      sqlContent.writeln('-- Control Finanzas - Backup Completo');
      sqlContent.writeln('-- Fecha: ${now.toIso8601String()}');
      sqlContent.writeln('-- Versión DB: ${await db.getVersion()}');
      sqlContent.writeln();
      
      // Obtener todas las tablas
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'"
      );
      
      for (var table in tables) {
        final tableName = table['name'] as String;
        sqlContent.writeln('-- Tabla: $tableName');
        
        // Obtener estructura de la tabla
        final tableInfo = await db.rawQuery('PRAGMA table_info($tableName)');
        sqlContent.writeln('CREATE TABLE IF NOT EXISTS $tableName (');
        
        final columns = tableInfo.map((col) {
          final name = col['name'];
          final type = col['type'];
          final notNull = col['notnull'] == 1 ? ' NOT NULL' : '';
          final pk = col['pk'] == 1 ? ' PRIMARY KEY' : '';
          return '  $name $type$notNull$pk';
        }).join(',\n');
        
        sqlContent.writeln(columns);
        sqlContent.writeln(');');
        sqlContent.writeln();
        
        // Obtener datos
        final rows = await db.query(tableName);
        if (rows.isNotEmpty) {
          sqlContent.writeln('-- Datos de $tableName (${rows.length} registros)');
          for (var row in rows) {
            final columns = row.keys.join(', ');
            final values = row.values.map((v) {
              if (v == null) return 'NULL';
              if (v is String) return "'${v.replaceAll("'", "''")}'";
              return v.toString();
            }).join(', ');
            sqlContent.writeln('INSERT INTO $tableName ($columns) VALUES ($values);');
          }
          sqlContent.writeln();
        }
      }
      
      // Guardar archivo
      await file.writeAsString(sqlContent.toString());
      
      return backupPath;
    } catch (e) {
      throw Exception('Error al exportar SQL: $e');
    }
  }

  // Importar base de datos desde un archivo
  Future<bool> importDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      
      // Verificar que el archivo existe
      if (!await backupFile.exists()) {
        throw Exception('El archivo de backup no existe');
      }
      
      // Cerrar la base de datos actual
      final db = await DatabaseHelper.instance.database;
      final dbPath = db.path;
      await db.close();
      
      // Reemplazar la base de datos actual con el backup
      await backupFile.copy(dbPath);
      
      // Reabrir la base de datos
      await DatabaseHelper.instance.database;
      
      return true;
    } catch (e) {
      throw Exception('Error al importar base de datos: $e');
    }
  }

  // Importar desde archivo seleccionado por el usuario
  Future<bool> importDatabaseFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Selecciona el archivo de backup',
        type: FileType.custom,
        allowedExtensions: ['db', 'sql'],
      );
      
      if (result == null || result.files.isEmpty) {
        return false; // Usuario canceló
      }
      
      final filePath = result.files.single.path;
      if (filePath == null) {
        throw Exception('No se pudo obtener la ruta del archivo');
      }
      
      return await importDatabase(filePath);
    } catch (e) {
      throw Exception('Error al importar: $e');
    }
  }

  // Obtener lista de backups disponibles
  Future<List<FileSystemEntity>> getBackupFiles() async {
    try {
      final backupsDir = await getBackupsDirectory();
      
      if (!await backupsDir.exists()) {
        return [];
      }
      
      final files = backupsDir.listSync()
          .where((file) => file is File && file.path.endsWith('.db'))
          .toList();
      
      // Ordenar por fecha de modificación (más reciente primero)
      files.sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });
      
      return files;
    } catch (e) {
      return [];
    }
  }

  // Eliminar un archivo de backup
  Future<bool> deleteBackup(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Obtener tamaño del archivo de backup
  Future<int> getBackupSize(String backupPath) async {
    try {
      final file = File(backupPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Formatear tamaño de archivo
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Obtener nombre legible del backup
  String getBackupDisplayName(String backupPath) {
    final fileName = path.basename(backupPath);
    
    try {
      // Formato: wealthvault_backup_2025-11-19_14-30-45.db
      final dateStr = fileName
          .replaceAll('wealthvault_backup_', '')
          .replaceAll('.db', '');
      
      final parts = dateStr.split('_');
      if (parts.length == 2) {
        final datePart = parts[0].split('-');
        final timePart = parts[1].split('-');
        
        if (datePart.length == 3 && timePart.length == 3) {
          return '${datePart[2]}/${datePart[1]}/${datePart[0]} ${timePart[0]}:${timePart[1]}';
        }
      }
      
      return fileName;
    } catch (e) {
      return fileName;
    }
  }

  // Verificar si hay backups disponibles
  Future<bool> hasBackups() async {
    final files = await getBackupFiles();
    return files.isNotEmpty;
  }

  // Obtener el último backup
  Future<String?> getLatestBackup() async {
    final files = await getBackupFiles();
    if (files.isEmpty) return null;
    return files.first.path;
  }
}
