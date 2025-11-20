# 🚀 Guía de Inicio Rápido - ChronoWealth

## Primer Uso

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Ejecutar la Aplicación
```bash
flutter run
```

## 📖 Uso de la Aplicación

### Pantalla Principal (Dashboard)
Al abrir la app verás:
- **Card superior**: Tu balance total en todas las categorías
- **Grid de categorías**: 8 categorías predefinidas con sus balances

### Agregar una Transacción
1. Toca el botón flotante **"+ Transacción"** (esquina inferior derecha)
2. Selecciona el tipo:
   - **Ingreso** (verde): Para dinero que entra
   - **Gasto** (rojo): Para dinero que sale
3. Elige la categoría del dropdown
4. Ingresa el **monto** (solo números)
5. Escribe una **descripción** (mínimo 3 caracteres)
6. Ajusta la **fecha y hora** si es necesario
7. Presiona **"Guardar Transacción"**

### Ver Detalle de una Categoría
1. Toca cualquier **tarjeta de categoría** en el dashboard
2. Verás:
   - Balance de esa categoría
   - Lista de todas las transacciones
   - Cada transacción muestra: descripción, fecha y monto

### Eliminar una Transacción
1. En la pantalla de detalle de categoría
2. **Desliza hacia la izquierda** cualquier transacción
3. Confirma la eliminación
4. ¡Listo! El balance se actualiza automáticamente

### Actualizar Datos
- **Pull-to-refresh**: Desliza hacia abajo en el dashboard para refrescar
- **Botón refresh**: Toca el icono de actualizar en la barra superior

## 💡 Categorías Disponibles

| Categoría | Descripción | Ícono |
|-----------|-------------|-------|
| Cuentas Bancarias | Dinero en bancos | 🏦 |
| Inversiones | Acciones, bonos, fondos | 📈 |
| Criptomonedas | Bitcoin, Ethereum, etc. | ₿ |
| Trading | Operaciones de trading | 📊 |
| Préstamos | Dinero prestado a otros | 🤝 |
| Propiedades | Bienes raíces | 🏠 |
| Efectivo | Dinero en efectivo | 💵 |
| Otros Activos | Cualquier otro activo | 📦 |

## 🎨 Características Visuales

### Colores por Tipo
- **Ingreso**: Verde (#50C878)
- **Gasto**: Rojo (#FF6B6B)
- **Balance positivo**: Flecha arriba verde
- **Balance negativo**: Flecha abajo roja

### Diseño Cromado
- Fondo oscuro elegante
- Cards con efecto metálico
- Sombras suaves
- Bordes con brillo sutil

## 📊 Cálculos Automáticos

- **Balance por categoría** = Suma de ingresos - Suma de gastos
- **Balance total** = Suma de todos los balances de categorías
- Los cálculos se actualizan en tiempo real al agregar/eliminar transacciones

## ⚡ Atajos y Tips

1. **Agregar rápido desde categoría**: 
   - Entra a una categoría
   - Toca el **+** en la barra superior
   - La categoría ya estará preseleccionada

2. **Fechas**:
   - Por defecto usa la fecha y hora actual
   - Puedes cambiarla tocando el selector de fecha

3. **Montos**:
   - Acepta decimales con punto: `1234.56`
   - Solo números positivos
   - Se formatea automáticamente con símbolo de moneda

4. **Descripciones útiles**:
   - "Salario de Noviembre"
   - "Compra en supermercado"
   - "Dividendos de acciones"
   - "Depósito en cuenta"

## 🗄️ Base de Datos

- Toda la información se guarda **localmente** en tu dispositivo
- No requiere internet
- Los datos persisten entre sesiones
- Base de datos: `chronowealth.db` en el almacenamiento de la app

## ❓ Solución de Problemas

### La app no muestra datos
1. Verifica que agregaste al menos una transacción
2. Toca el botón de refresh
3. Pull-to-refresh en el dashboard

### No puedo agregar transacciones
1. Verifica que llenaste todos los campos
2. El monto debe ser mayor a 0
3. La descripción debe tener al menos 3 caracteres

### El balance no se actualiza
1. Regresa al dashboard
2. Haz pull-to-refresh
3. La app recalculará todos los balances

## 🎯 Mejores Prácticas

1. **Sé específico en las descripciones** para recordar cada transacción
2. **Registra transacciones regularmente** para mantener el control
3. **Usa las categorías correctas** para análisis más precisos
4. **Revisa periódicamente** el detalle de cada categoría

---

**¡Disfruta gestionando tus finanzas con ChronoWealth! 💰✨**
