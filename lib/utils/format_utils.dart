import 'package:intl/intl.dart';

class FormatUtils {
  // Formateador de moneda MXN
  static final currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
    locale: 'es_MX',
    name: 'MXN',
  );

  // Formateador de moneda sin decimales MXN
  static final currencyFormatterNoDecimals = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
    locale: 'es_MX',
    name: 'MXN',
  );

  // Formateador de fecha completa
  static final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es');

  // Formateador de fecha corta
  static final shortDateFormatter = DateFormat('dd MMM yyyy', 'es');

  // Formateador de hora
  static final timeFormatter = DateFormat('HH:mm', 'es');

  // Formateador de fecha para mostrar
  static final displayDateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'es');

  // Formatear moneda
  static String formatCurrency(double amount, {bool showDecimals = true}) {
    if (showDecimals) {
      return currencyFormatter.format(amount);
    } else {
      return currencyFormatterNoDecimals.format(amount);
    }
  }

  // Formatear fecha
  static String formatDate(DateTime date, {bool includeTime = true}) {
    if (includeTime) {
      return dateFormatter.format(date);
    } else {
      return shortDateFormatter.format(date);
    }
  }

  // Obtener el nombre del mes
  static String getMonthName(DateTime date) {
    return DateFormat('MMMM', 'es').format(date);
  }

  // Formatear número con separador de miles
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'es_MX');
    return formatter.format(number);
  }

  // Formatear moneda compacta (para cantidades grandes)
  static String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M MXN';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K MXN';
    } else {
      return formatCurrency(amount);
    }
  }

  // Obtener fecha relativa (Hoy, Ayer, etc.)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Justo ahora';
        }
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hoy a las ${timeFormatter.format(date)}';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${timeFormatter.format(date)}';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return shortDateFormatter.format(date);
    }
  }
}
