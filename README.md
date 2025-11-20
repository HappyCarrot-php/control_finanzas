# WealthVault 💎

**Tu Patrimonio, Tu Futuro**

Una aplicación moderna y elegante de gestión de finanzas personales con diseño plateado cromado minimalista.

## 🌟 Características

### Gestión de Activos Financieros
La aplicación permite organizar tus finanzas en múltiples categorías:

- **Cuentas Bancarias** - Gestiona el dinero en tus cuentas corrientes y de ahorro
- **Inversiones** - Registra el valor de tus inversiones en bolsa, fondos, etc.
- **Criptomonedas** - Controla tu portafolio de criptoactivos
- **Trading** - Mantén registro de tus operaciones de trading
- **Préstamos** - Registra el total que tienes en préstamos (activos)
- **Propiedades** - Valor de tus bienes inmuebles
- **Efectivo** - Dinero en efectivo que posees
- **Otros Activos** - Cualquier otro tipo de activo financiero

### Funcionalidades Principales

✅ **CRUD Completo** - Create, Read, Update, Delete para todas las transacciones
- ➕ **Crear**: Agregar transacciones desde múltiples puntos
- 👁️ **Leer**: Ver en Dashboard, Categorías e Historial completo
- ✏️ **Editar**: Toca cualquier transacción para editarla
- 🗑️ **Eliminar**: Desliza hacia la izquierda con confirmación

✅ **Dashboard Interactivo** - Balance total, Drawer con opciones y grid de categorías

✅ **Gastos Recurrentes** ⚡ - Sistema de gestión de gastos típicos del hogar:
- 8 plantillas predefinidas: Luz, Agua, Gas, Internet, Teléfono, Renta, Despensa, Transporte
- Registro rápido con montos sugeridos personalizables
- Historial de gastos por categoría
- Visualización con colores e iconos distintivos
- Edición y eliminación con swipe

✅ **Carrito de Compras** 🛒 - Lista inteligente de productos:
- Agregar productos con nombre, precio y cantidad
- Cálculo automático de totales
- Edición táctil de productos
- Eliminación por swipe
- "Checkout" que registra la compra como gasto
- Notas opcionales por producto
- Limpieza rápida del carrito

✅ **Historial Completo** - Vista de todas las transacciones agrupadas por fecha con:
- Estadísticas diarias (ingresos, gastos, balance neto)
- Contador de transacciones por día
- Edición táctil
- Eliminación por swipe

✅ **Transacciones Detalladas** - Registra ingresos y gastos con:
- Monto en MXN (Pesos Mexicanos) con formato local
- Descripción
- Fecha y hora personalizable
- Categoría con icono y color

✅ **Base de Datos Local (SQLite v2)** - Todos los datos almacenados localmente:
- Sistema de migración automática
- Tablas para transacciones, categorías, gastos recurrentes y carrito
- Sin necesidad de conexión a internet
- Backups completos en carpeta dedicada

✅ **Diseño Cromado Moderno** - Interfaz plateada con efectos metálicos, sombras suaves y colores vibrantes

✅ **Gestión por Categorías** - Cada categoría tiene:
- Vista detallada de transacciones
- Balance individual actualizado en tiempo real
- Historial completo
- Edición y eliminación de transacciones

## 🎨 Diseño

- **Tema**: Oscuro con tonos plateados brillantes y metálicos
- **Colores**: Paleta de plata con gradientes y acentos vibrantes
- **Efecto**: Acero inoxidable pulido con reflejos metálicos
- **Estilo**: Minimalista, moderno, con efectos de profundidad 3D
- **UX**: Intuitiva, con animaciones suaves y transiciones fluidas
- **Splash Screen**: Pantalla de carga animada con el logo de la app

## 🚀 Tecnologías

- **Flutter** - Framework multiplataforma
- **SQLite** (sqflite) - Base de datos local
- **Provider** - Gestión de estado
- **FL Chart** - Gráficos (preparado para futuros análisis)
- **Intl** - Formateo de fechas y números en español

## 📱 Cómo usar

### ➕ Crear Transacción (CREATE):
1. Presiona el botón flotante **"Transacción"** en el dashboard
2. O abre el drawer y selecciona **"Nueva Transacción"**
3. O toca **"+"** en el detalle de una categoría
4. Selecciona si es **Ingreso** o **Gasto**
5. Elige la **categoría**
6. Ingresa el **monto en MXN** y **descripción**
7. Selecciona la **fecha y hora**
8. Presiona **"Guardar Transacción"**

### ⚡ Registrar Gastos Recurrentes:
1. Abre el **drawer lateral** (☰)
2. Selecciona **"Gastos Recurrentes"**
3. Elige la plantilla de gasto (Luz, Agua, Gas, etc.)
4. El monto sugerido aparece automáticamente (puedes modificarlo)
5. Agrega notas opcionales
6. Selecciona la fecha
7. Presiona **"Guardar"**
8. Ver historial con el botón de reloj ⏱

### 🛒 Usar el Carrito de Compras:
1. Abre el **drawer lateral** (☰)
2. Selecciona **"Carrito de Compras"**
3. Presiona el botón **"+"** azul
4. Ingresa **nombre del producto**, **precio en MXN** y **cantidad**
5. Agrega notas si lo deseas
6. El total se calcula automáticamente
7. **Editar**: Toca un producto para modificarlo
8. **Eliminar**: Desliza hacia la izquierda
9. **Finalizar Compra**: Presiona el botón verde "Finalizar"
10. La compra se registra automáticamente como gasto
11. El carrito se limpia tras confirmar

### 👁️ Ver Transacciones (READ):
- **Dashboard**: Balance total y resumen por categorías
- **Historial** (🕐): Todas las transacciones agrupadas por fecha
- **Detalle de Categoría**: Transacciones específicas de cada categoría

### ✏️ Editar Transacción (UPDATE):
1. Abre el **Historial** o el **Detalle de Categoría**
2. **Toca** la transacción que deseas editar
3. Se abre el formulario con los datos precargados
4. Modifica lo que necesites
5. Presiona **"Actualizar Transacción"**

### 🗑️ Eliminar Transacción (DELETE):
1. Abre el **Historial** o el **Detalle de Categoría**
2. **Desliza hacia la izquierda** la transacción
3. Aparece el fondo rojo con icono de papelera
4. Confirma la eliminación
5. La transacción se elimina permanentemente

### 💾 Gestionar Backups:
1. Abre el **drawer lateral** (☰)
2. Selecciona **"Backup"**
3. **Exporta** tu base de datos (crea copia con timestamp en carpeta dedicada)
4. **Ver Backups** para administrar copias guardadas
5. **Restaura** desde cualquier backup anterior
6. **Elimina** backups antiguos que no necesites
7. Los backups se guardan en: `Documents/WealthVault_Backups/`

### 📊 Dashboard:
- **Balance Total**: Tarjeta superior con tu patrimonio total en MXN
- **Drawer Lateral**: Acceso a Dashboard, Historial, Nueva Transacción, Gastos Recurrentes, Carrito y Backup
- **Grid de Categorías**: 8 categorías con balance individual
- **Pull-to-refresh**: Desliza hacia abajo para actualizar
- **Botón flotante**: Agregar transacción rápida

## 🔧 Instalación

1. Clona el repositorio
2. Ejecuta `flutter pub get`
3. Ejecuta `flutter run`

## 📊 Base de Datos

La aplicación utiliza SQLite versión 2 con sistema de migración automática. Estructura de tablas:

- **categories**: Almacena las categorías financieras (Cuentas Bancarias, Inversiones, etc.)
- **transactions**: Almacena todas las transacciones (ingresos y gastos)
- **expense_templates**: Plantillas de gastos recurrentes con iconos y montos sugeridos
- **shopping_cart_items**: Productos en el carrito de compras con precio, cantidad y notas

Las categorías y plantillas de gastos se crean automáticamente en la primera ejecución.
La migración de v1 a v2 es automática y preserva todos los datos existentes.

## 💾 Sistema de Backup Mejorado

✅ **Carpeta Dedicada**: Backups organizados en `Documents/WealthVault_Backups/`
✅ **Exportar Base de Datos**: Crea copias de seguridad automáticas con timestamp
✅ **Importar/Restaurar**: Recupera tus datos desde cualquier backup guardado
✅ **Gestión de Backups**: Lista, visualiza y elimina backups anteriores
✅ **Almacenamiento Persistente**: Backups accesibles incluso tras desinstalar la app
✅ **Formato Legible**: Nombres de archivo claros: `wealthvault_backup_YYYY-MM-DD_HH-mm-ss.db`

### Características del Backup:
- Exportación con un solo toque
- Backups con fecha/hora automática clara
- Carpeta dedicada fácil de encontrar
- Lista visual de todos los backups con tamaño
- Restauración con confirmación de seguridad
- Eliminación segura de backups antiguos
- Compatibilidad con exploradores de archivos

## 🎯 Próximas Funcionalidades

- Dashboard con gráficos estadísticos (ingresos vs gastos, tendencias)
- Pantalla Home con tabs de Ingresos/Gastos
- Gráficos de tendencias con FL Chart
- Exportación a CSV/PDF
- Filtros avanzados por fechas y categorías
- Estadísticas detalladas mensuales y anuales
- Widgets para home screen
- Compartir backups por WhatsApp/Email
- Nuevo logo en splash screen
- Mejoras visuales en diseño cromado

## 📄 Licencia

Este proyecto está bajo tu control total - úsalo, modifícalo y distribúyelo como desees.

## 🎨 Icono de la App

El icono de WealthVault presenta:
- Diseño metálico plateado brillante
- Símbolo de billetera/bóveda con signo de dólar
- Efecto 3D con sombras y reflejos
- Gradientes plateados profesionales
- Compatible con Android e iOS

Para regenerar el icono:
```bash
python generate_icon.py
dart run flutter_launcher_icons
```

---

**WealthVault** 💎 - Tu Patrimonio, Tu Futuro 🚀
