import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final FinancialCategory category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(category.color, radix: 16));

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTransactionScreen(
                    preselectedCategory: category,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          final balance = provider.getCategoryBalance(category.id!);
          final transactions = provider.getTransactionsByCategory(category.id!);
          final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

          return Column(
            children: [
              // Card de balance de la categoría
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: AppTheme.shinyCard(
                  color: color,
                  borderRadius: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconData(category.icon),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          balance >= 0 ? Icons.trending_up : Icons.trending_down,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Balance en ${category.name}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${transactions.length} transaccion${transactions.length != 1 ? 'es' : ''}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de transacciones
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: AppTheme.chromeMedium.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay transacciones',
                              style: TextStyle(
                                color: AppTheme.chromeMedium.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Presiona + para agregar una',
                              style: TextStyle(
                                color: AppTheme.chromeMedium.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundCard,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.chromeMedium.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 16,
                                        color: AppTheme.chromeMedium.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Toca para editar',
                                        style: TextStyle(
                                          color: AppTheme.chromeMedium.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.swipe_left,
                                        size: 16,
                                        color: AppTheme.chromeMedium.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Desliza para eliminar',
                                        style: TextStyle(
                                          color: AppTheme.chromeMedium.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return _buildTransactionItem(
                            context,
                            transaction,
                            color,
                            formatter,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    FinancialTransaction transaction,
    Color categoryColor,
    NumberFormat formatter,
  ) {
    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm', 'es');
    final isIncome = transaction.type == 'income';

    return Dismissible(
      key: Key(transaction.id.toString()),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: AppTheme.chromeContainer(
          color: AppTheme.accentRed.withOpacity(0.3),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.backgroundCard,
            title: const Text('Confirmar eliminación', style: TextStyle(color: AppTheme.chromeLight)),
            content: const Text('¿Deseas eliminar esta transacción?', style: TextStyle(color: AppTheme.chromeMedium)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<FinanceProvider>().deleteTransaction(transaction.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transacción eliminada'),
            backgroundColor: AppTheme.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          // Navegar a la pantalla de edición
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                transactionToEdit: transaction,
                preselectedCategory: category,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.chromeContainer(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isIncome ? AppTheme.accentGreen : AppTheme.accentRed)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isIncome ? Icons.add : Icons.remove,
                  color: isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        color: AppTheme.chromeLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(transaction.date),
                      style: TextStyle(
                        color: AppTheme.chromeMedium.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'} ${formatter.format(transaction.amount)}',
                    style: TextStyle(
                      color: isIncome ? AppTheme.accentGreen : AppTheme.accentRed,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: AppTheme.chromeMedium.withOpacity(0.5),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'account_balance': Icons.account_balance,
      'trending_up': Icons.trending_up,
      'currency_bitcoin': Icons.currency_bitcoin,
      'show_chart': Icons.show_chart,
      'handshake': Icons.handshake,
      'home': Icons.home,
      'payments': Icons.payments,
      'inventory_2': Icons.inventory_2,
    };
    return iconMap[iconName] ?? Icons.account_balance_wallet;
  }
}
