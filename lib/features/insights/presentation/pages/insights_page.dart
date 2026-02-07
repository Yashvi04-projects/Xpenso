import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../features/dashboard/presentation/utils/dashboard_ui_helpers.dart';
import '../../../../features/expenses/domain/repositories/expense_repository.dart';
import '../providers/insights_provider.dart';
import 'package:xpenso/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../widgets/category_breakdown_item.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InsightsProvider(
         Provider.of<ExpenseRepository>(context, listen: false),
      )..loadInsights(),
      child: const _InsightsView(),
    );
  }
}

class _InsightsView extends StatelessWidget {
  const _InsightsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<InsightsProvider>(context); // Changed to InsightsProvider
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final formatter = NumberFormat.simpleCurrency(name: dashboardProvider.currency, decimalDigits: 2);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios_new, color: theme.colorScheme.onSurface, size: 20),
        centerTitle: true,
        title: Text(
          'SPENDING INSIGHTS', 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: theme.colorScheme.onSurface, 
            letterSpacing: 1.0
          )
        ),
        actions: [
          Icon(Icons.notifications, color: theme.colorScheme.onSurface),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timeframe Selector
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildTab(context, 'Weekly', false, provider),
                  _buildTab(context, 'Monthly', true, provider), // Mock selected
                  _buildTab(context, 'Yearly', false, provider),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Total Amount
            Text(
              formatter.format(provider.totalSpent),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 if (provider.totalSpent > 0) ... [
                   const Icon(Icons.trending_up, color: Colors.grey, size: 16),
                   const SizedBox(width: 4),
                   const Text(
                     "Spending breakdown for the current month",
                     style: TextStyle(color: Colors.grey, fontSize: 14),
                   )
                 ],
              ],
            ),

            const SizedBox(height: 32),

            // Donut Chart
            SizedBox(
              height: 200,
              child: Stack(
                children: [
                   PieChart(
                     PieChartData(
                       sectionsSpace: 0,
                       centerSpaceRadius: 70,
                       startDegreeOffset: -90,
                       sections: _generateChartSections(provider),
                     ),
                   ),
                   Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text("TOP SPENDING", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5)),
                           const SizedBox(height: 4),
                           Text(
                             provider.categoryBreakdown.isNotEmpty 
                              ? DashboardUIHelpers.getCategoryName(provider.categoryBreakdown.first.categoryId)
                              : "None",
                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                           ),
                        ],
                      ),
                   ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Smart Insight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? theme.cardColor : const Color(0xFFE8F5E9).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF386641), // Deep green
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Smart Insight",
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.smartInsight,
                          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Category Breakdown Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Category Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                ),
                TextButton(
                  onPressed: (){},
                   child: Text("See all", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            
            // List
            if (provider.isLoading)
              const CircularProgressIndicator()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.categoryBreakdown.length,
                itemBuilder: (context, index) => CategoryBreakdownItem(data: provider.categoryBreakdown[index]),
              ),
              
             const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool isActive, InsightsProvider provider) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => provider.setTimeframe(label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? (theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? theme.colorScheme.primary : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateChartSections(InsightsProvider provider) {
    if (provider.categoryBreakdown.isEmpty) return [];

    // Stitch Palette
    final colors = [
      const Color(0xFF386641), // Deep Green
      const Color(0xFF6A994E), // Medium Green
      const Color(0xFFA7C957), // Light Green
      const Color(0xFFF2E8CF), // Cream
    ];

    return List.generate(provider.categoryBreakdown.length, (i) {
      final item = provider.categoryBreakdown[i];
      final isTop = i == 0;
      final radius = isTop ? 25.0 : 20.0;
      final color = colors[i % colors.length];

      return PieChartSectionData(
        color: color,
        value: item.percentage,
        title: '', // No title on chart itself per design, center contains text
        radius: radius,
        showTitle: false,
      );
    });
  }
}
