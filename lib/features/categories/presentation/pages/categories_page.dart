import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/dashboard/presentation/utils/dashboard_ui_helpers.dart';
import '../../domain/repositories/category_repository.dart';
import '../providers/categories_provider.dart';

import '../../../../features/expenses/domain/repositories/expense_repository.dart';
import '../../domain/entities/category.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoriesProvider(
        Provider.of<CategoryRepository>(context, listen: false),
        Provider.of<ExpenseRepository>(context, listen: false),
      )..loadBudgets(),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatelessWidget {
  const _CategoriesView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoriesProvider>(context);
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 0, locale: 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
       appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Budgets',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimaryLight),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF1B4332), // Dark Green
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: () => _showCategoryDialog(context, provider),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 24),

            // Summary Card
            _buildSummaryCard(provider, formatter),

            const SizedBox(height: 24),

            // List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Breakdowns',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tap on any category to edit its limit")));
                  },
                  child: const Text('Edit Limits', style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 16),

             // Budget List
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.budgets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildBudgetCard(context, provider, provider.budgets[index], formatter);
                  },
              ),

             const SizedBox(height: 24),

             // Add Category Dashed Button
             InkWell(
                  onTap: () {
                    _showCategoryDialog(context, provider);
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        style: BorderStyle.solid, 
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                         Icon(Icons.add, color: Color(0xFF1B4332), size: 24),
                         SizedBox(height: 12),
                         Text(
                          'Add New Category',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'SET LIMITS FOR BETTER TRACKING',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
              const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CategoriesProvider provider, NumberFormat formatter) {
    double progress = 0;
    if (provider.totalBudget > 0) {
      progress = (provider.totalSpent / provider.totalBudget).clamp(0.0, 1.0);
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.02),
             blurRadius: 10,
             offset: const Offset(0, 4),
           )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text(
                    'TOTAL MONTHLY BUDGET',
                    style: TextStyle(
                       color: AppColors.textSecondaryLight,
                       fontSize: 10,
                       fontWeight: FontWeight.bold,
                       letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: formatter.format(provider.totalSpent),
                      style: const TextStyle(
                         color: Color(0xFF1B4332),
                         fontSize: 28,
                         fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: ' / ${formatter.format(provider.totalBudget)}',
                          style: const TextStyle(
                             color: Colors.grey,
                             fontSize: 16,
                             fontWeight: FontWeight.normal,
                          ),
                        )
                      ]
                    )
                  ),
                 ],
               ),
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.green.shade50,
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: const Icon(Icons.account_balance_wallet, color: Color(0xFF1B4332)),
               ),
             ],
           ),
           
           const SizedBox(height: 24),
           
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text("Overall Spending", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
               Text("${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
             ],
           ),
           const SizedBox(height: 8),
           LinearProgressIndicator(
             value: progress,
             backgroundColor: Colors.grey.shade200,
             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1B4332)),
             minHeight: 12,
             borderRadius: BorderRadius.circular(6),
           ),
           const SizedBox(height: 16),
           
           Row(
             children: [
                // Circles
                SizedBox(
                  width: 40,
                  height: 20,
                  child: Stack(
                     children: [
                       Positioned(left: 0, child: _circle(Colors.green.shade100)),
                       Positioned(left: 10, child: _circle(Colors.green.shade500)),
                       Positioned(left: 20, child: _circle(const Color(0xFF1B4332))),
                     ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${formatter.format(provider.totalBudget - provider.totalSpent)} remaining this month",
                   style: const TextStyle(
                       color: Color(0xFF1B4332),
                       fontSize: 12,
                       fontWeight: FontWeight.bold,
                    ),
                )
             ],
           )
        ],
      ),
    );
  }

  Widget _circle(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, CategoriesProvider provider, CategoryBudget budget, NumberFormat formatter) {
     final percentUsed = budget.percent;
     final isExceeded = budget.isOverBudget;
     
     Color statusColor = const Color(0xFF1B4332); // Default green
     String statusText = "HEALTHY • ${percentUsed.toStringAsFixed(0)}% USED";

     if (isExceeded) {
       statusColor = Colors.redAccent;
       statusText = "EXCEEDED BY ${formatter.format(budget.spent - budget.category.monthlyLimit)}";
     } else if (percentUsed > 80) {
       statusColor = Colors.orange;
       statusText = "${percentUsed.toStringAsFixed(0)}% USED";
     } else if (percentUsed == 100) {
        statusColor = const Color(0xFF1B4332);
        statusText = "PAID FULL";
     }

     return InkWell(
       onTap: () {
         showModalBottomSheet(
           context: context,
           builder: (ctx) => Wrap(
             children: [
               ListTile(
                 leading: const Icon(Icons.edit),
                 title: const Text('Edit Category / Set Limit'),
                 onTap: () {
                   Navigator.pop(ctx);
                   _showCategoryDialog(context, provider, categoryToEdit: budget.category);
                 },
               ),
               ListTile(
                 leading: const Icon(Icons.delete, color: Colors.red),
                 title: const Text('Delete Category', style: TextStyle(color: Colors.red)),
                 onTap: () async {
                   Navigator.pop(ctx);
                   final confirm = await showDialog<bool>(
                     context: context, 
                     builder: (c) => AlertDialog(
                       title: const Text("Delete Category?"),
                       content: const Text("This will remove the category. Existing expenses in this category might be affected."),
                       actions: [
                         TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
                         TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                       ],
                     )
                   );
                   if (confirm == true) {
                     provider.deleteCategory(budget.category.id);
                   }
                 },
               ),
             ],
           ),
         );
       },
       child: Container(
         padding: const EdgeInsets.all(20),
         decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.01),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Column(
          children: [
             Row(
               children: [
                 Container(
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: isExceeded ? Colors.red.shade50 : (percentUsed > 80 ? Colors.orange.shade50 : Colors.green.shade50),
                     shape: BoxShape.circle,
                   ),
                   child: Icon(
                     DashboardUIHelpers.getCategoryIcon(budget.category.id),
                     color: isExceeded ? Colors.red : (percentUsed > 80 ? Colors.orange : const Color(0xFF1B4332)),
                     size: 20,
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         budget.category.name,
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           if (isExceeded) const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                           if (isExceeded) const SizedBox(width: 4),
                           Text(
                             statusText,
                             style: TextStyle(
                               fontSize: 10, 
                               fontWeight: FontWeight.bold, 
                               color: statusColor,
                               letterSpacing: 0.5,
                             ),
                           ),
                         ],
                       )
                     ],
                   ),
                 ),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     Text(
                         formatter.format(budget.spent),
                         style: TextStyle(
                           fontSize: 16, 
                           fontWeight: FontWeight.bold, 
                           color: isExceeded ? Colors.red : AppColors.textPrimaryLight
                          ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         "LIMIT: ${formatter.format(budget.category.monthlyLimit)}",
                         style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
                       ),
                   ],
                 ),
               ],
             ),
             const SizedBox(height: 16),
             LinearProgressIndicator(
               value: budget.progress,
               backgroundColor: Colors.grey.shade100,
               valueColor: AlwaysStoppedAnimation<Color>(statusColor),
               minHeight: 8,
               borderRadius: BorderRadius.circular(4),
             ),
          ],
        ),
       ),
     );
  }

  void _showCategoryDialog(BuildContext context, CategoriesProvider provider, {Category? categoryToEdit}) {
    final nameController = TextEditingController(text: categoryToEdit?.name ?? '');
    final limitController = TextEditingController(text: categoryToEdit?.monthlyLimit.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(categoryToEdit == null ? "New Category" : "Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
               decoration: const InputDecoration(labelText: "Category Name", hintText: "e.g., Groceries"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: limitController,
              decoration: const InputDecoration(labelText: "Monthly Limit", hintText: "e.g., 5000"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final limit = double.tryParse(limitController.text.trim()) ?? 0.0;
              
              if (name.isNotEmpty) {
                if (categoryToEdit != null) {
                  provider.updateCategory(categoryToEdit.copyWith(name: name, monthlyLimit: limit));
                } else {
                   provider.addCategory(Category(id: '', userId: '', name: name, monthlyLimit: limit, icon: 'category_default', color: 0xFF000000));
                }
                Navigator.pop(context);
              }
            }, 
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
