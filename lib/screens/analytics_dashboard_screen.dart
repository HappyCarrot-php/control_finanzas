import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/format_utils.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Overview
                _buildBalanceOverview(provider),
                const SizedBox(height: 24),

                // Income vs Expenses
                Text(
                  'Ingresos vs Gastos (Mes Actual)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildIncomeExpenseBar(provider),
                const SizedBox(height: 24),

                // Category Distribution Pie Chart
                Text(
                  'Distribución por Categorías',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildCategoryPieChart(provider),
                const SizedBox(height: 24),

                // Transaction Trend Line Chart
                Text(
                  'Tendencia de Transacciones',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildTransactionTrendChart(provider),
                const SizedBox(height: 24),

                // Quick Stats
                Text(
                  'Estadísticas Rápidas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.chromeLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildQuickStats(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceOverview(FinanceProvider provider) {
    final currentMonth = DateTime.now();
    final monthlyTransactions = provider.transactions.where((t) {
      return t.date.year == currentMonth.year && t.date.month == currentMonth.month;
    }).toList();

    final totalIncome = monthlyTransactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.silverMedium, AppTheme.chromeMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceStat('Ingresos', totalIncome, AppTheme.accentGreen, Icons.arrow_upward),
              Container(width: 1, height: 50, color: Colors.white24),
              _buildBalanceStat('Gastos', totalExpenses, AppTheme.accentRed, Icons.arrow_downward),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance Total',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    FormatUtils.formatCurrency(provider.totalBalance),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(String label, double amount, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            FormatUtils.formatCurrency(amount),
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseBar(FinanceProvider provider) {
    final currentMonth = DateTime.now();
    final monthlyTransactions = provider.transactions.where((t) {
      return t.date.year == currentMonth.year && t.date.month == currentMonth.month;
    }).toList();

    final totalIncome = monthlyTransactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final totalExpenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);

    final maxValue = (totalIncome > totalExpenses ? totalIncome : totalExpenses) * 1.2;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.chromeDark),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxValue > 0 ? maxValue : 1000,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalIncome,
                  color: AppTheme.accentGreen,
                  width: 50,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: totalExpenses,
                  color: AppTheme.accentRed,
                  width: 50,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  return Text(
                    FormatUtils.formatCurrency(value),
                    style: TextStyle(color: AppTheme.chromeMedium, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return Text('Ingresos', style: TextStyle(color: AppTheme.accentGreen, fontSize: 12, fontWeight: FontWeight.bold));
                    case 1:
                      return Text('Gastos', style: TextStyle(color: AppTheme.accentRed, fontSize: 12, fontWeight: FontWeight.bold));
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.chromeDark.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(FinanceProvider provider) {
    if (provider.categories.isEmpty) {
      return _buildEmptyChart('No hay datos de categorías');
    }

    final categoryData = provider.categories.where((cat) {
      final balance = provider.getCategoryBalance(cat.id!);
      return balance > 0;
    }).map((cat) {
      return {
        'category': cat,
        'balance': provider.getCategoryBalance(cat.id!),
      };
    }).toList();

    if (categoryData.isEmpty) {
      return _buildEmptyChart('No hay categorías con balance positivo');
    }

    final total = categoryData.fold<double>(0, (sum, item) => sum + (item['balance'] as double));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.chromeDark),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: categoryData.asMap().entries.map((entry) {
                  final item = entry.value;
                  final category = item['category'] as dynamic;
                  final balance = item['balance'] as double;
                  final percentage = (balance / total * 100);
                  final color = Color(int.parse(category.color, radix: 16));

                  return PieChartSectionData(
                    value: balance,
                    title: '${percentage.toStringAsFixed(1)}%',
                    color: color,
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryData.map((item) {
                  final category = item['category'] as dynamic;
                  final balance = item['balance'] as double;
                  final color = Color(int.parse(category.color, radix: 16));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: TextStyle(
                                  color: AppTheme.chromeLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                FormatUtils.formatCurrency(balance),
                                style: TextStyle(
                                  color: AppTheme.chromeMedium,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTrendChart(FinanceProvider provider) {
    if (provider.transactions.isEmpty) {
      return _buildEmptyChart('No hay transacciones para mostrar');
    }

    // Obtener últimos 7 días
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day - (6 - i));
    });

    final dailyBalances = last7Days.map((day) {
      final dayTransactions = provider.transactions.where((t) {
        return t.date.year == day.year &&
            t.date.month == day.month &&
            t.date.day == day.day;
      }).toList();

      final income = dayTransactions
          .where((t) => t.type == 'income')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final expense = dayTransactions
          .where((t) => t.type == 'expense')
          .fold<double>(0, (sum, t) => sum + t.amount);

      return income - expense;
    }).toList();

    final maxY = dailyBalances.reduce((a, b) => a.abs() > b.abs() ? a : b).abs() * 1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.chromeDark),
      ),
      child: LineChart(
        LineChartData(
          maxY: (maxY > 0 ? maxY : 1000).toDouble(),
          minY: -(maxY > 0 ? maxY : 1000).toDouble(),
          lineBarsData: [
            LineChartBarData(
              spots: dailyBalances.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.toDouble());
              }).toList(),
              isCurved: true,
              color: AppTheme.accentBlue,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, _) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppTheme.accentBlue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accentBlue.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '\$${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(color: AppTheme.chromeMedium, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < last7Days.length) {
                    final day = last7Days[index];
                    return Text(
                      '${day.day}',
                      style: TextStyle(color: AppTheme.chromeMedium, fontSize: 10),
                    );
                  }
                  return Text('');
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppTheme.chromeDark.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildQuickStats(FinanceProvider provider) {
    final avgTransactionAmount = provider.transactions.isEmpty
        ? 0.0
        : provider.transactions.fold<double>(0, (sum, t) => sum + t.amount) /
            provider.transactions.length;

    final biggestExpense = provider.transactions
        .where((t) => t.type == 'expense')
        .fold<double>(0, (max, t) => t.amount > max ? t.amount : max);

    final biggestIncome = provider.transactions
        .where((t) => t.type == 'income')
        .fold<double>(0, (max, t) => t.amount > max ? t.amount : max);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Transacciones',
          provider.transactions.length.toString(),
          Icons.receipt,
          AppTheme.accentBlue,
        ),
        _buildStatCard(
          'Promedio',
          FormatUtils.formatCurrency(avgTransactionAmount),
          Icons.analytics,
          AppTheme.accentOrange,
        ),
        _buildStatCard(
          'Mayor Ingreso',
          FormatUtils.formatCurrency(biggestIncome),
          Icons.arrow_circle_up,
          AppTheme.accentGreen,
        ),
        _buildStatCard(
          'Mayor Gasto',
          FormatUtils.formatCurrency(biggestExpense),
          Icons.arrow_circle_down,
          AppTheme.accentRed,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentBlue, AppTheme.accentBlue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.chromeMedium,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.chromeDark),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: AppTheme.chromeMedium,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.chromeMedium,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
