import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final List<Map<String, dynamic>> _expenseTemplates = [
    {
      'name': 'Luz',
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
      'defaultAmount': 500.0,
    },
    {
      'name': 'Agua',
      'icon': Icons.water_drop_outlined,
      'color': Colors.blue,
      'defaultAmount': 300.0,
    },
    {
      'name': 'Gas',
      'icon': Icons.local_fire_department_outlined,
      'color': Colors.orange,
      'defaultAmount': 400.0,
    },
    {
      'name': 'Internet',
      'icon': Icons.wifi,
      'color': Colors.purple,
      'defaultAmount': 600.0,
    },
    {
      'name': 'Saldo',
      'icon': Icons.phone_android,
      'color': Colors.green,
      'defaultAmount': 350.0,
    },
    {
      'name': 'Renta',
      'icon': Icons.home_outlined,
      'color': Colors.red,
      'defaultAmount': 5000.0,
    },
    {
      'name': 'Despensa',
      'icon': Icons.shopping_cart_outlined,
      'color': Colors.teal,
      'defaultAmount': 2000.0,
    },
    {
      'name': 'Gasolina',
      'icon': Icons.local_gas_station,
      'color': Colors.indigo,
      'defaultAmount': 800.0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              Color(0xFF202433),
              AppTheme.backgroundCard,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: AppTheme.chromeContainer(
                    color: AppTheme.backgroundCard.withOpacity(0.96),
                    borderRadius: 28,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gastos Recurrentes',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.chromeLight,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.history),
                              onPressed: () => _showExpensesHistory(context),
                              color: AppTheme.chromeMedium,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _expenseTemplates.length,
                          itemBuilder: (context, index) {
                            return _buildExpenseCard(_expenseTemplates[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.chromeLight),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Gestión de Gastos',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.chromeLight,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Registra tus gastos recurrentes',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.chromeMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> template) {
    return GestureDetector(
      onTap: () => _showExpenseDialog(template),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (template['color'] as Color).withOpacity(0.35),
              AppTheme.backgroundCard,
            ],
          ),
          border: Border.all(
            color: (template['color'] as Color).withOpacity(0.45),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppTheme.silverBright.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showExpenseDialog(template),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      template['icon'],
                      size: 40,
                      color: AppTheme.chromeLight,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    template['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.chromeLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    FormatUtils.formatCurrency(template['defaultAmount']),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.chromeMedium,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.chromeMedium),
      prefixIcon: icon != null ? Icon(icon, color: AppTheme.accentBlue) : null,
      filled: true,
      fillColor: AppTheme.backgroundCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppTheme.chromeMedium.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppTheme.chromeMedium.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppTheme.accentBlue, width: 2),
      ),
    );
  }

  void _showExpenseDialog(Map<String, dynamic> template) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final amountController = TextEditingController(
      text: template['defaultAmount'].toString(),
    );
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    FinancialCategory? selectedCategory = provider.categories.isNotEmpty ? provider.categories.first : null;
    FinancialTransaction? selectedIncomeTransaction;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Obtener transacciones de ingreso de la categoría seleccionada
            final incomeTransactions = (selectedCategory?.id != null)
                ? provider.transactions
                    .where((t) => t.type == 'income' && t.categoryId == selectedCategory!.id)
                    .toList()
                : <FinancialTransaction>[];

            return AlertDialog(
              backgroundColor: AppTheme.backgroundCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (template['color'] as Color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      template['icon'],
                      color: template['color'],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Registrar ${template['name']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Categoría',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.chromeLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCardLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.chromeMedium.withOpacity(0.35),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<FinancialCategory>(
                          value: selectedCategory,
                          isExpanded: true,
                          style: const TextStyle(
                            color: AppTheme.chromeLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          dropdownColor: AppTheme.backgroundCardLight,
                          items: provider.categories.map((cat) {
                            final color = Color(int.parse(cat.color, radix: 16));
                            return DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    cat.name,
                                    style: const TextStyle(color: AppTheme.chromeLight),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (cat) {
                            setState(() {
                              selectedCategory = cat;
                              selectedIncomeTransaction = null;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'De dónde sacar el dinero',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppTheme.chromeLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundCardLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.chromeMedium.withOpacity(0.35),
                        ),
                      ),
                      child: incomeTransactions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'No hay ingresos registrados en esta categoría',
                                style: const TextStyle(
                                  color: AppTheme.chromeMedium,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<FinancialTransaction?>(
                                value: selectedIncomeTransaction,
                                isExpanded: true,
                                style: const TextStyle(
                                  color: AppTheme.chromeLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                dropdownColor: AppTheme.backgroundCardLight,
                                hint: const Text(
                                  'Seleccionar origen (opcional)',
                                  style: TextStyle(color: AppTheme.chromeMedium),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'General - Sin origen específico',
                                      style: TextStyle(color: AppTheme.chromeLight),
                                    ),
                                  ),
                                  ...incomeTransactions.map((income) {
                                    return DropdownMenuItem(
                                      value: income,
                                      child: Text(
                                        '${income.description} (${FormatUtils.formatCurrency(income.amount)})',
                                        style: const TextStyle(color: AppTheme.chromeLight),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (income) {
                                  setState(() {
                                    selectedIncomeTransaction = income;
                                  });
                                },
                              ),
                            ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: amountController,
                      decoration: _dialogInputDecoration(
                        label: 'Monto (MXN)',
                        icon: Icons.attach_money,
                      ),
                      style: const TextStyle(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.w600,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: notesController,
                      decoration: _dialogInputDecoration(
                        label: 'Notas (opcional)',
                        icon: Icons.note_outlined,
                      ),
                      style: const TextStyle(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: template['color'],
                                  surface: AppTheme.backgroundCard,
                                  onSurface: AppTheme.chromeLight,
                                ),
                                dialogBackgroundColor: AppTheme.backgroundCard,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundCardLight,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppTheme.chromeMedium.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: template['color']),
                            const SizedBox(width: 15),
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.chromeLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.chromeLight,
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor selecciona una categoría')),
                      );
                      return;
                    }
                    _saveExpense(
                      template,
                      double.tryParse(amountController.text) ?? template['defaultAmount'],
                      notesController.text,
                      selectedDate,
                      selectedCategory!,
                      selectedIncomeTransaction,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: template['color'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveExpense(
    Map<String, dynamic> template,
    double amount,
    String notes,
    DateTime date,
    FinancialCategory category,
    FinancialTransaction? sourceIncomeTransaction,
  ) async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    
    // Verificar que la categoría tenga ID
    if (category.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Categoría inválida')),
      );
      return;
    }

    // Crear la transacción vinculada al ingreso de origen si se seleccionó
    final transaction = FinancialTransaction(
      type: 'expense',
      categoryId: category.id!,
      subcategoryId: sourceIncomeTransaction?.id, // Vincular al ID de la transacción de ingreso
      amount: amount,
      description: notes.isEmpty 
          ? 'Pago de ${template['name']} - ${category.name}${sourceIncomeTransaction != null ? ' (Desde: ${sourceIncomeTransaction.description})' : ''}'
          : notes,
      date: date,
    );

    await provider.addTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto de ${template['name']} registrado'),
          backgroundColor: template['color'],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showExpensesHistory(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final allTransactions = provider.transactions;
    
    // Filter only expense transactions
    final expenseTransactions = allTransactions
        .where((t) => t.type == 'expense')
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.chromeMedium.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial de Gastos',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.chromeLight,
                    ),
                  ),
                  Text(
                    '${expenseTransactions.length} registros',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.chromeMedium,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: expenseTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: AppTheme.chromeDark.withOpacity(0.35),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No hay gastos registrados',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppTheme.chromeMedium,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: expenseTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = expenseTransactions[index];
                        
                        try {
                          provider.categories.firstWhere(
                            (cat) => cat.id == transaction.categoryId,
                          );
                        } catch (e) {
                          // Category not found, use default
                        }
                        
                        // Try to find matching template based on description
                        String expenseName = 'Gasto';
                        for (var template in _expenseTemplates) {
                          if (transaction.description.toLowerCase().contains(template['name'].toLowerCase())) {
                            expenseName = template['name'];
                            break;
                          }
                        }
                        
                        final template = _expenseTemplates.firstWhere(
                          (t) => t['name'] == expenseName,
                          orElse: () => {
                            'name': expenseName,
                            'icon': Icons.payment,
                            'color': Colors.grey,
                          },
                        );

                        return Dismissible(
                          key: Key(transaction.id.toString()),
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRed,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            provider.deleteTransaction(transaction.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gasto eliminado'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundCardLight,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppTheme.chromeMedium.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: template['color'].withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  template['icon'],
                                  color: template['color'],
                                ),
                              ),
                              title: Text(
                                template['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.chromeLight,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (transaction.description.isNotEmpty)
                                    Text(
                                      transaction.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.chromeMedium,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    FormatUtils.formatDate(
                                      transaction.date,
                                      includeTime: false,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.chromeMedium,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '-${FormatUtils.formatCurrency(transaction.amount)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: template['color'],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
