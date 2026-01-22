import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';
import 'expenses_screen.dart';
import 'movements_screen.dart';
import 'shopping_cart_screen.dart';
import 'transactions_history_screen.dart';

class ActionsSection extends StatelessWidget {
  const ActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final actionItems = _buildActionItems(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final targetColumns = maxWidth >= 1024
            ? 3
            : maxWidth >= 720
                ? 2
                : 1;
        final effectiveWidth = maxWidth.isFinite ? maxWidth : MediaQuery.of(context).size.width;
        final spacing = 16.0;
        final itemWidth = targetColumns > 0
            ? (effectiveWidth - (spacing * (targetColumns - 1))) / targetColumns
            : effectiveWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: actionItems
              .map((item) => _ActionCard(data: item, width: itemWidth))
              .toList(),
        );
      },
    );
  }

  List<_ActionData> _buildActionItems(BuildContext context) {
    return [
      _ActionData(
        title: 'Registrar ingreso',
        description:
            'Añade nuevas entradas de capital y actualiza tus movimientos en segundos.',
        icon: Icons.trending_up,
        accent: AppTheme.accentGreen,
        ctaLabel: 'Agregar ingreso',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(initialType: 'income'),
            ),
          );
        },
      ),
      _ActionData(
        title: 'Registrar gasto',
        description:
            'Controla tus egresos y descuenta del movimiento correspondiente al instante.',
        icon: Icons.trending_down,
        accent: AppTheme.accentRed,
        ctaLabel: 'Agregar gasto',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(initialType: 'expense'),
            ),
          );
        },
      ),
      _ActionData(
        title: 'Gestionar movimientos',
        description:
            'Edita saldos, renombra y organiza los movimientos que conforman tu capital.',
        icon: Icons.account_balance_wallet_outlined,
        accent: AppTheme.accentBlue,
        ctaLabel: 'Administrar',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MovementsScreen(),
            ),
          );
        },
      ),
      _ActionData(
        title: 'Historial completo',
        description:
            'Consulta, filtra y modifica todas tus transacciones en un solo lugar.',
        icon: Icons.history_toggle_off,
        accent: AppTheme.accentPurple,
        ctaLabel: 'Ver historial',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionsHistoryScreen(),
            ),
          );
        },
      ),
      _ActionData(
        title: 'Gastos recurrentes',
        description: 'Monitorea servicios esenciales y actualiza montos programados.',
        icon: Icons.receipt_long,
        accent: AppTheme.accentOrange,
        ctaLabel: 'Gestionar gastos',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ExpensesScreen(),
            ),
          );
        },
      ),
      _ActionData(
        title: 'Carrito de compras',
        description: 'Controla tus compras planeadas y mantén tu presupuesto bajo control.',
        icon: Icons.shopping_cart_checkout,
        accent: AppTheme.accentGold,
        ctaLabel: 'Ver carrito',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShoppingCartScreen(),
            ),
          );
        },
      ),
    ];
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.data, required this.width});

  final _ActionData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    final boundedWidth = width.clamp(260.0, 420.0).toDouble();
    return SizedBox(
      width: boundedWidth,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.chromeContainer(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    data.accent.withOpacity(0.85),
                    data.accent,
                    data.accent.withOpacity(0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: data.accent.withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                data.icon,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    color: AppTheme.chromeLight,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              data.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.chromeMedium,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: data.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: data.onTap,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(
                data.ctaLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionData {
  _ActionData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.ctaLabel,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final String ctaLabel;
  final VoidCallback onTap;
}
