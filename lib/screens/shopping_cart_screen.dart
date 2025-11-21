import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/shopping_cart_item.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ShoppingCartItem> _cartItems = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    setState(() => _isLoading = true);
    
    try {
      final items = await _dbHelper.getAllCartItems();
      final total = await _dbHelper.getCartTotal();
      
      setState(() {
        _cartItems = items;
        _totalAmount = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar carrito: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentOrange,
              AppTheme.accentOrange.withOpacity(0.8),
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
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTotalCard(),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _cartItems.isEmpty
                                ? _buildEmptyCart()
                                : _buildCartList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_cartItems.isNotEmpty) ...[
            FloatingActionButton.extended(
              heroTag: 'checkout',
              onPressed: _checkout,
              backgroundColor: AppTheme.accentGreen,
              icon: const Icon(Icons.shopping_bag),
              label: const Text('Finalizar'),
            ),
            const SizedBox(height: 10),
          ],
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _showAddItemDialog,
            backgroundColor: AppTheme.accentBlue,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrito de Compras',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Agrega productos y precios',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: _clearCart,
              tooltip: 'Limpiar carrito',
            ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentOrange, AppTheme.accentOrange.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                FormatUtils.formatCurrency(_totalAmount),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${_cartItems.length}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'Carrito vacío',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Agrega productos para comenzar',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Dismissible(
          key: Key(item.id.toString()),
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) async {
            await _dbHelper.deleteCartItem(item.id!);
            _loadCartItems();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Producto eliminado'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: GestureDetector(
            onTap: () => _showEditItemDialog(item),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_basket,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Cantidad: ${item.quantity}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentBlue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'c/u ${FormatUtils.formatCurrency(item.price)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.note, size: 14, color: Colors.grey[400]),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatUtils.formatCurrency(item.total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddItemDialog() {
    final productNameController = TextEditingController(text: 'Producto');
    final priceController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();

    // Seleccionar el texto automáticamente cuando se enfoque
    WidgetsBinding.instance.addPostFrameCallback((_) {
      productNameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: productNameController.text.length,
      );
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_shopping_cart, color: AppTheme.accentBlue),
            ),
            const SizedBox(width: 15),
            const Text('Agregar Producto'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productNameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  labelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: const Icon(Icons.shopping_basket, color: Colors.black87),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                textCapitalization: TextCapitalization.words,
                onTap: () {
                  // Seleccionar todo el texto al hacer clic
                  productNameController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: productNameController.text.length,
                  );
                },
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio Unitario (MXN)',
                        labelStyle: const TextStyle(color: Colors.black87),
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.black87),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: const TextStyle(color: Colors.black87),
                        prefixIcon: const Icon(Icons.shopping_cart, color: Colors.black87),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.number,
                      onTap: () {
                        // Seleccionar todo el texto al hacer clic
                        quantityController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: quantityController.text.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  labelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: const Icon(Icons.note_outlined, color: Colors.black87),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (productNameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete los campos requeridos')),
                );
                return;
              }

              final item = ShoppingCartItem(
                productName: productNameController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
                quantity: int.tryParse(quantityController.text) ?? 1,
                notes: notesController.text.isEmpty ? null : notesController.text,
                dateAdded: DateTime.now(),
              );

              await _dbHelper.addCartItem(item);
              _loadCartItems();
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto agregado'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(ShoppingCartItem item) {
    final productNameController = TextEditingController(text: item.productName);
    final priceController = TextEditingController(text: item.price.toString());
    final quantityController = TextEditingController(text: item.quantity.toString());
    final notesController = TextEditingController(text: item.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: AppTheme.accentOrange),
            ),
            const SizedBox(width: 15),
            const Text('Editar Producto'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del producto',
                  labelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: const Icon(Icons.shopping_basket, color: Colors.black87),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: priceController,
                      decoration: InputDecoration(
                        labelText: 'Precio Unitario (MXN)',
                        labelStyle: const TextStyle(color: Colors.black87),
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.black87),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: const TextStyle(color: Colors.black87),
                        prefixIcon: const Icon(Icons.shopping_cart, color: Colors.black87),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notas (opcional)',
                  labelStyle: const TextStyle(color: Colors.black87),
                  prefixIcon: const Icon(Icons.note_outlined, color: Colors.black87),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (productNameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete los campos requeridos')),
                );
                return;
              }

              final updatedItem = item.copyWith(
                productName: productNameController.text,
                price: double.tryParse(priceController.text) ?? item.price,
                quantity: int.tryParse(quantityController.text) ?? item.quantity,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );

              await _dbHelper.updateCartItem(updatedItem);
              _loadCartItems();
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producto actualizado'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Limpiar Carrito'),
        content: const Text('¿Estás seguro de que deseas eliminar todos los productos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.clearCart();
      _loadCartItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carrito limpiado'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _checkout() async {
    if (_cartItems.isEmpty) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    
    if (provider.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay categorías disponibles')),
      );
      return;
    }

    // Mostrar diálogo de selección de categoría y transacción de ingreso
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        FinancialCategory? selectedCategory = provider.categories.first;
        FinancialTransaction? selectedIncomeTransaction;

        return StatefulBuilder(
          builder: (context, setState) {
            // Obtener transacciones de ingreso de la categoría seleccionada
            final incomeTransactions = (selectedCategory?.id != null)
                ? provider.transactions
                    .where((t) => t.type == 'income' && t.categoryId == selectedCategory!.id)
                    .toList()
                : <FinancialTransaction>[];

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag, color: AppTheme.accentGreen),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Finalizar Compra',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total a registrar:'),
                    const SizedBox(height: 5),
                    Text(
                      FormatUtils.formatCurrency(_totalAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${_cartItems.length} productos',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 15),
                    // Selector de categoría
                    const Text(
                      'Categoría',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<FinancialCategory>(
                          value: selectedCategory,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                          dropdownColor: Colors.white,
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
                                    style: const TextStyle(color: Colors.black87),
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
                    // Selector de ingreso - Mostrar transacciones de ingreso existentes
                    const Text(
                      'De dónde sacar el dinero',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: incomeTransactions.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                'No hay ingresos registrados en esta categoría',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<FinancialTransaction?>(
                                value: selectedIncomeTransaction,
                                isExpanded: true,
                                style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
                                dropdownColor: Colors.white,
                                hint: const Text(
                                  'Seleccionar origen (opcional)',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'General - Sin origen específico',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                  ...incomeTransactions.map((income) {
                                    return DropdownMenuItem(
                                      value: income,
                                      child: Text(
                                        '${income.description} (${FormatUtils.formatCurrency(income.amount)})',
                                        style: const TextStyle(color: Colors.black87),
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
                    Navigator.pop(context, {
                      'category': selectedCategory,
                      'incomeTransaction': selectedIncomeTransaction,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        final FinancialCategory category = result['category'];
        final FinancialTransaction? sourceIncomeTransaction = result['incomeTransaction'];

        // Create transaction with all cart items in description
        final itemsList = _cartItems.map((item) => 
          '${item.productName} (${item.quantity}x${FormatUtils.formatCurrency(item.price)})'
        ).join(', ');

        final transaction = FinancialTransaction(
          type: 'expense',
          categoryId: category.id!,
          subcategoryId: sourceIncomeTransaction?.id, // Vincular al ID de la transacción de ingreso
          amount: _totalAmount,
          description: 'Compra: $itemsList${sourceIncomeTransaction != null ? ' (Desde: ${sourceIncomeTransaction.description})' : ''}',
          date: DateTime.now(),
        );

        await provider.addTransaction(transaction);
        
        await _dbHelper.clearCart();
        
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compra registrada exitosamente'),
              backgroundColor: AppTheme.accentGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al registrar compra: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
