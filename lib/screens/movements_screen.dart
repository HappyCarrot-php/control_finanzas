import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/subcategory.dart';
import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';

class MovementsScreen extends StatefulWidget {
  const MovementsScreen({super.key});

  @override
  State<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends State<MovementsScreen> {
  bool _requestedInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requestedInitialLoad) {
      _requestedInitialLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<FinanceProvider>().loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz_rounded, size: 20, color: AppTheme.accentBlue),
            SizedBox(width: 10),
            Text('Movimientos'),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showMovementForm(context),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Nuevo movimiento'),
        ),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.subcategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subcategories.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                final movements = provider
                    .getSubcategoriesByCategory(category.id!)
                  ..sort((a, b) => a.order.compareTo(b.order));

                if (movements.isEmpty) {
                  return const SizedBox.shrink();
                }

                return _buildCategorySection(context, category, movements);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 40,
                color: AppTheme.accentBlue.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin movimientos aún',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea un movimiento para llevar el control de tus cuentas dentro de cada categoría.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.chromeMedium.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showMovementForm(context),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Crear movimiento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    FinancialCategory category,
    List<Subcategory> movements,
  ) {
    final categoryColor = Color(int.parse(category.color, radix: 16));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.chromeMedium.withValues(alpha: 0.08),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        collapsedIconColor: AppTheme.chromeMedium.withValues(alpha: 0.5),
        iconColor: AppTheme.accentBlue,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(category.icon),
                color: categoryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: AppTheme.chromeLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${movements.length} movimiento${movements.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppTheme.chromeMedium.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: movements
            .map((movement) => _buildMovementTile(context, movement))
            .toList(),
      ),
    );
  }

  Widget _buildMovementTile(BuildContext context, Subcategory movement) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCardLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.name,
                      style: const TextStyle(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${movement.createdDate.day}/${movement.createdDate.month}/${movement.createdDate.year}',
                      style: TextStyle(
                        color: AppTheme.chromeMedium.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                FormatUtils.formatCurrency(movement.balance),
                style: TextStyle(
                  color: movement.balance >= 0
                      ? AppTheme.accentGreen
                      : AppTheme.accentRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          if (movement.isInterestBearing && movement.interestRate > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_graph_rounded, size: 12, color: AppTheme.accentBlue),
                      const SizedBox(width: 4),
                      Text(
                        'GAT ${movement.interestRate.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: AppTheme.accentBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showMovementForm(context, movement: movement),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined, size: 18, color: AppTheme.chromeMedium.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _confirmDelete(context, movement),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline, size: 18, color: AppTheme.accentRed.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
          ],
          if (!movement.isInterestBearing || movement.interestRate <= 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showMovementForm(context, movement: movement),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined, size: 18, color: AppTheme.chromeMedium.withValues(alpha: 0.5)),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _confirmDelete(context, movement),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline, size: 18, color: AppTheme.accentRed.withValues(alpha: 0.6)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showMovementForm(BuildContext context, {Subcategory? movement}) async {
    final provider = context.read<FinanceProvider>();
    final categories = provider.categories;

    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea una categoría')), 
      );
      return;
    }

    FinancialCategory selectedCategory;
    if (movement != null) {
      selectedCategory = categories.firstWhere((c) => c.id == movement.categoryId);
    } else {
      selectedCategory = categories.first;
    }

    final nameController = TextEditingController(text: movement?.name ?? '');
    final balanceController = TextEditingController(
      text: movement?.balance.toStringAsFixed(2) ?? '0.00',
    );
    final initialRate = movement?.interestRate ?? 0.0;
    final gatController = TextEditingController(
      text: initialRate > 0 ? initialRate.toStringAsFixed(2) : '',
    );
    bool isInterestEnabled = movement?.isInterestBearing ?? false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.chromeMedium.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      movement == null ? 'Nuevo movimiento' : 'Editar movimiento',
                      style: const TextStyle(
                        color: AppTheme.chromeLight,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<FinancialCategory>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      dropdownColor: AppTheme.backgroundCardLight,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: movement == null
                          ? (value) {
                              if (value != null) {
                                setModalState(() {
                                  selectedCategory = value;
                                });
                              }
                            }
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del movimiento',
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      maxLength: 50,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: balanceController,
                      decoration: const InputDecoration(
                        labelText: 'Balance actual',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: AppTheme.backgroundCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.chromeMedium.withValues(alpha: 0.08))),
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            value: isInterestEnabled,
                            onChanged: (value) {
                              setModalState(() {
                                isInterestEnabled = value;
                                if (!value) {
                                  gatController.clear();
                                } else if (gatController.text.isEmpty && initialRate > 0) {
                                  gatController.text = initialRate.toStringAsFixed(2);
                                }
                              });
                            },
                            title: const Text('Interés compuesto diario'),
                            subtitle: const Text(
                              'Aplicará el GAT anual cada día a las 12:00 para simular el saldo real.',
                            ),
                            activeColor: AppTheme.accentBlue,
                          ),
                          if (isInterestEnabled)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: TextFormField(
                                controller: gatController,
                                decoration: const InputDecoration(
                                  labelText: 'GAT anual (%)',
                                  prefixIcon: Icon(Icons.percent),
                                  helperText: 'Ingresa la tasa anual, ej. 13',
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,4}')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final name = nameController.text.trim();
                              final balance = double.tryParse(balanceController.text) ?? 0;

                              if (name.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ingresa un nombre válido')),
                                );
                                return;
                              }

                              double interestRate = 0.0;
                              DateTime? lastInterestApplied = movement?.lastInterestApplied;

                              if (isInterestEnabled) {
                                final sanitized = gatController.text
                                    .replaceAll('%', '')
                                    .replaceAll(',', '.')
                                    .trim();
                                interestRate = double.tryParse(sanitized) ?? 0.0;

                                if (interestRate <= 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ingresa un GAT válido mayor a 0')),
                                  );
                                  return;
                                }

                                if (!(movement?.isInterestBearing ?? false)) {
                                  lastInterestApplied = DateTime.now();
                                }
                              } else {
                                interestRate = 0.0;
                                lastInterestApplied = null;
                              }

                              try {
                                if (movement == null) {
                                  final newMovement = Subcategory(
                                    categoryId: selectedCategory.id!,
                                    name: name,
                                    balance: balance,
                                    order: provider
                                            .getSubcategoriesByCategory(selectedCategory.id!)
                                            .length +
                                        1,
                                    isInterestBearing: isInterestEnabled,
                                    interestRate: interestRate,
                                    lastInterestApplied: isInterestEnabled ? DateTime.now() : null,
                                  );
                                  await provider.addSubcategory(newMovement);
                                } else {
                                  await provider.updateSubcategory(
                                    movement.copyWith(
                                      name: name,
                                      balance: balance,
                                      isInterestBearing: isInterestEnabled,
                                      interestRate: interestRate,
                                      lastInterestApplied: lastInterestApplied,
                                    ),
                                  );
                                }

                                if (!mounted) return;
                                Navigator.pop(context);
                              } catch (error) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $error')),
                                );
                              }
                            },
                            child: Text(movement == null ? 'Crear' : 'Guardar cambios'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    balanceController.dispose();
    gatController.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, Subcategory movement) async {
    final provider = context.read<FinanceProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          title: const Text('Eliminar movimiento'),
          content: Text(
            '¿Seguro que deseas eliminar "${movement.name}"? Esta acción no afecta tus transacciones pasadas, pero dejará de estar disponible para nuevos registros.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await provider.deleteSubcategory(movement.id!);
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
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
