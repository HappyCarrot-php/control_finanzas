import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../models/subcategory.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final FinancialCategory? preselectedCategory;
  final FinancialTransaction? transactionToEdit;

  const AddTransactionScreen({
    super.key,
    this.preselectedCategory,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  FinancialCategory? _selectedCategory;
  Subcategory? _selectedSubcategory;
  FinancialTransaction? _selectedIncomeSource; // Para gastos: de qué ingreso sacar
  String _transactionType = 'income';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.preselectedCategory;

    if (widget.transactionToEdit != null) {
      final transaction = widget.transactionToEdit!;
      _amountController.text = transaction.amount.toString();
      _descriptionController.text = transaction.description;
      _transactionType = transaction.type;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<FinanceProvider>();

    if (_selectedCategory == null && widget.preselectedCategory == null) {
      _selectedCategory = provider.categories.isNotEmpty ? provider.categories.first : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'Nueva Transacción' : 'Editar Transacción'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Selector de tipo de transacción
              Container(
                decoration: AppTheme.chromeContainer(),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton('Ingreso', 'income', AppTheme.accentGreen),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTypeButton('Gasto', 'expense', AppTheme.accentRed),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Selector de categoría
              Text(
                'Categoría',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                decoration: AppTheme.chromeContainer(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FinancialCategory>(
                    value: _selectedCategory,
                    isExpanded: true,
                    dropdownColor: AppTheme.backgroundCard,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.chromeMedium),
                    style: const TextStyle(color: AppTheme.chromeLight, fontSize: 16),
                    items: provider.categories.map((category) {
                      final color = Color(int.parse(category.color, radix: 16));
                      return DropdownMenuItem<FinancialCategory>(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              _getIconData(category.icon),
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: widget.preselectedCategory == null
                        ? (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedSubcategory = null; // Reset subcategory cuando cambia categoría
                              _selectedIncomeSource = null; // Reset apartado cuando cambia categoría
                            });
                          }
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Selector de apartado/movimiento según tipo de transacción
              if (_selectedCategory != null) ...[
                // Para INGRESOS: selector de subcategorías (movimientos)
                if (_transactionType == 'income') ...[
                  Row(
                    children: [
                      Text(
                        'Movimiento',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showAddSubcategoryDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: AppTheme.chromeContainer(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: Consumer<FinanceProvider>(
                        builder: (context, provider, child) {
                          final subcategories = provider.getSubcategoriesByCategory(_selectedCategory!.id!);
                          
                          if (subcategories.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No hay movimientos. Agrega uno.',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            );
                          }

                          return DropdownButton<Subcategory>(
                            value: _selectedSubcategory,
                            isExpanded: true,
                            dropdownColor: AppTheme.backgroundCard,
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.chromeMedium),
                            style: const TextStyle(color: AppTheme.chromeLight, fontSize: 16),
                            hint: const Text('Selecciona un movimiento'),
                            items: subcategories.map((subcategory) {
                              final color = subcategory.color != null 
                                  ? Color(int.parse(subcategory.color!, radix: 16))
                                  : AppTheme.chromeMedium;
                              return DropdownMenuItem<Subcategory>(
                                value: subcategory,
                                child: Row(
                                  children: [
                                    if (subcategory.icon != null)
                                      Icon(
                                        _getIconData(subcategory.icon!),
                                        color: color,
                                        size: 20,
                                      )
                                    else
                                      Icon(Icons.account_balance_wallet, color: color, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(subcategory.name)),
                                    Text(
                                      '\$${subcategory.balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: subcategory.balance >= 0 ? AppTheme.accentGreen : AppTheme.accentRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubcategory = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
                // Para GASTOS: selector de apartados (ingresos existentes)
                if (_transactionType == 'expense') ...[
                  Text(
                    'Seleccionar Apartado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: AppTheme.chromeContainer(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: Consumer<FinanceProvider>(
                        builder: (context, provider, child) {
                          // Obtener transacciones de ingreso de la categoría seleccionada
                          final incomeTransactions = provider.transactions
                              .where((t) => t.type == 'income' && t.categoryId == _selectedCategory!.id)
                              .toList();
                          
                          if (incomeTransactions.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'No hay ingresos registrados en esta categoría',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            );
                          }

                          return DropdownButton<FinancialTransaction?>(
                            value: _selectedIncomeSource,
                            isExpanded: true,
                            dropdownColor: AppTheme.backgroundCard,
                            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.chromeMedium),
                            style: const TextStyle(color: AppTheme.chromeLight, fontSize: 16),
                            hint: const Text('Selecciona de dónde sacar (opcional)'),
                            items: [
                              const DropdownMenuItem<FinancialTransaction?>(
                                value: null,
                                child: Row(
                                  children: [
                                    Icon(Icons.layers_clear, color: AppTheme.chromeMedium, size: 20),
                                    SizedBox(width: 12),
                                    Text('General - Sin apartado específico'),
                                  ],
                                ),
                              ),
                              ...incomeTransactions.map((income) {
                                return DropdownMenuItem<FinancialTransaction?>(
                                  value: income,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.account_balance_wallet, color: AppTheme.accentGreen, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          income.description,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '\$${income.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppTheme.accentGreen,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedIncomeSource = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],

              // Campo de monto
              Text(
                'Monto',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingresa un monto válido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'El monto debe ser mayor a 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Campo de descripción
              Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Ej: Salario, compra, inversión...',
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa una descripción';
                  }
                  if (value.length < 3) {
                    return 'La descripción debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Selector de fecha
              Text(
                'Fecha',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppTheme.chromeContainer(),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.chromeMedium),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm', 'es').format(_selectedDate),
                        style: const TextStyle(
                          color: AppTheme.chromeLight,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.chromeMedium),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Botón de guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _transactionType == 'income' 
                      ? AppTheme.accentGreen 
                      : AppTheme.accentRed,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.transactionToEdit == null ? 'Guardar Transacción' : 'Actualizar Transacción',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, Color color) {
    final isSelected = _transactionType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = type;
          _selectedSubcategory = null; // Reset al cambiar tipo
          _selectedIncomeSource = null; // Reset al cambiar tipo
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'income' ? Icons.add_circle : Icons.remove_circle,
              color: isSelected ? Colors.white : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    if (!mounted) return;
    
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentBlue,
              onPrimary: Colors.white,
              surface: AppTheme.backgroundCard,
              onSurface: AppTheme.chromeLight,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppTheme.accentBlue,
                onPrimary: Colors.white,
                surface: AppTheme.backgroundCard,
                onSurface: AppTheme.chromeLight,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = FinancialTransaction(
        id: widget.transactionToEdit?.id,
        categoryId: _selectedCategory!.id!,
        subcategoryId: _transactionType == 'income' 
            ? _selectedSubcategory?.id // Para ingresos: ID de subcategoría
            : _selectedIncomeSource?.id, // Para gastos: ID de transacción de ingreso
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        type: _transactionType,
      );

      final provider = context.read<FinanceProvider>();
      
      if (widget.transactionToEdit == null) {
        await provider.addTransaction(transaction);
        // Actualizar balance de subcategoría si se seleccionó una (solo para ingresos)
        if (_transactionType == 'income' && _selectedSubcategory != null) {
          await provider.updateSubcategoryBalance(
            _selectedSubcategory!.id!,
            double.parse(_amountController.text),
            _transactionType,
          );
        }
      } else {
        await provider.updateTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionToEdit == null 
                  ? 'Transacción guardada' 
                  : 'Transacción actualizada',
            ),
            backgroundColor: AppTheme.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAddSubcategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.00');
    final provider = context.read<FinanceProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nuevo Movimiento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nombre (ej: Nu Débito, BBVA Ahorro)',
                labelStyle: const TextStyle(color: Colors.black87),
                prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.black87),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: balanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Saldo Inicial (MXN)',
                labelStyle: const TextStyle(color: Colors.black87),
                prefixIcon: const Icon(Icons.attach_money, color: Colors.black87),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un nombre')),
                );
                return;
              }

              final balance = double.tryParse(balanceController.text) ?? 0.0;

              final subcategory = Subcategory(
                categoryId: _selectedCategory!.id!,
                name: name,
                balance: balance,
                order: provider.getSubcategoriesByCategory(_selectedCategory!.id!).length,
              );

              try {
                await provider.addSubcategory(subcategory);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Movimiento agregado'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                  setState(() {
                    // Actualizar UI para que aparezca en el dropdown
                  });
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Agregar'),
          ),
        ],
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
      'account_balance_wallet': Icons.account_balance_wallet,
    };
    return iconMap[iconName] ?? Icons.account_balance_wallet;
  }
}
