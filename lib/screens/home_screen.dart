import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../models/category.dart';
import '../utils/format_utils.dart';
import 'actions_screen.dart';
import 'category_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final isHidden = provider.isBalanceHidden;

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalBalanceCard(
                  provider.totalBalance,
                  isHidden,
                  () => provider.toggleBalanceVisibility(),
                ),
                const SizedBox(height: 24),
                Text(
                  'Activos Financieros',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                _buildCategoriesGrid(context, provider, isHidden),
                const SizedBox(height: 32),
                Text(
                  'Acciones rápidas',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                const ActionsSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalBalanceCard(
    double balance,
    bool isHidden,
    VoidCallback onToggle,
  ) {
    final displayBalance = isHidden ? '******' : FormatUtils.formatCurrency(balance);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A2744),
            Color(0xFF0F1B2D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.accentBlue.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentBlue, Color(0xFF3A7BD5)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance Total',
                      style: TextStyle(
                        color: AppTheme.chromeMedium,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actualizado: ${FormatUtils.formatDate(DateTime.now())}',
                      style: TextStyle(
                        color: AppTheme.chromeMedium.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Icon(
                      isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppTheme.chromeMedium,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            displayBalance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    FinanceProvider provider,
    bool isHidden,
  ) {
    if (provider.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: AppTheme.chromeMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'No hay categorías aún',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.chromeLight,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final entries = provider.categories
      .map((category) => MapEntry(category, provider.getCategoryBalance(category.id!)))
      .toList();
    entries.sort((a, b) => a.key.order.compareTo(b.key.order));
    final totalAbsBalance = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.value.abs(),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildCategoryCard(
          context,
          entry.key,
          entry.value,
          totalAbsBalance,
          isHidden,
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    FinancialCategory category,
    double balance,
    double totalAbsBalance,
    bool isHidden,
  ) {
    final color = Color(int.parse(category.color, radix: 16));
    final isPositive = balance >= 0;
    final participation = totalAbsBalance == 0
      ? 0.0
      : (balance.abs() / totalAbsBalance).clamp(0.0, 1.0).toDouble();
    final participationText = participation == 0
        ? '0%'
        : '${(participation * 100).toStringAsFixed(participation * 100 >= 10 ? 0 : 1)}%';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(category: category),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundCard,
              AppTheme.backgroundCardLight.withOpacity(0.6),
            ],
          ),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(category.icon),
                    color: color,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.chromeMedium.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    participationText,
                    style: const TextStyle(
                      color: AppTheme.chromeMedium,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              category.name,
              style: const TextStyle(
                color: AppTheme.chromeLight,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              isHidden ? '******' : FormatUtils.formatCurrency(balance),
              style: TextStyle(
                color: isPositive ? AppTheme.accentGreen : AppTheme.accentRed,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: participation,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.7)),
              ),
            ),
            const SizedBox(height: 8),
          ],
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
