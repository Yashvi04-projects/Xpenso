import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/services/expense_service.dart';
import '../providers/add_expense_provider.dart';

import '../../../categories/domain/repositories/category_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';

class AddExpensePage extends StatelessWidget {
  const AddExpensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddExpenseProvider(
        Provider.of<ExpenseService>(context, listen: false),
        Provider.of<CategoryRepository>(context, listen: false),
        Provider.of<AccountRepository>(context, listen: false),
      ),
      child: const _AddExpenseView(),
    );
  }
}

class _AddExpenseView extends StatelessWidget {
  const _AddExpenseView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddExpenseProvider>(context);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Match stitch design
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add Expense', style: TextStyle(color: theme.colorScheme.onSurface)),
        actions: [
          TextButton(
            onPressed: provider.reset,
            child: const Text('Reset', style: TextStyle(color: AppColors.primary)),
          ),
        ],
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   const SizedBox(height: 20),
                   const Text(
                     'TOTAL AMOUNT',
                     style: TextStyle(
                       fontSize: 12,
                       fontWeight: FontWeight.w600,
                       color: AppColors.textSecondaryLight,
                       letterSpacing: 1.2,
                     ),
                   ),
                   const SizedBox(height: 8),
                   // Amount Display
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     crossAxisAlignment: CrossAxisAlignment.baseline,
                     textBaseline: TextBaseline.alphabetic,
                     children: [
                       Text(
                         '₹',
                         style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: AppColors.primary,
                         ),
                       ),
                       const SizedBox(width: 4),
                       Text(
                         provider.amountStr,
                         style: TextStyle(
                           fontSize: 48,
                           fontWeight: FontWeight.bold,
                           color: theme.colorScheme.onSurface,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 32),
                   
                   // Categories
                   _buildSectionHeader('CATEGORY', 'ALL CATEGORIES'),
                   const SizedBox(height: 16),
                   SizedBox(
                     height: 80,
                     child: ListView.separated(
                       scrollDirection: Axis.horizontal,
                       itemCount: provider.categories.length,
                       separatorBuilder: (_, __) => const SizedBox(width: 20),
                       itemBuilder: (context, index) {
                         final cat = provider.categories[index];
                         final isSelected = cat.id == provider.selectedCategoryId;
                         return GestureDetector(
                           onTap: () => provider.setCategory(cat.id),
                           child: Column(
                             children: [
                               Container(
                                 width: 50,
                                 height: 50,
                                 decoration: BoxDecoration(
                                   color: isSelected ? AppColors.primary : (isDark ? theme.cardColor : const Color(0xFFF3F4F6)),
                                   shape: BoxShape.circle,
                                 ),
                                 child: Icon(
                                   _getCategoryIcon(cat.name),
                                   color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
                                 ),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 cat.name,
                                 style: TextStyle(
                                   fontSize: 12,
                                   fontWeight: FontWeight.w600,
                                   color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
                                 ),
                               ),
                             ],
                           ),
                         );
                       },
                     ),
                   ),

                   const SizedBox(height: 24),
                   
                   // Date & Time
                   // Date & Time
                   Row(
                     children: [
                       Expanded(
                         child: _buildPickerCard(
                           context,
                           icon: Icons.calendar_today_rounded,
                           label: 'DATE',
                           value: DateFormat('dd MMM, yyyy').format(provider.selectedDate),
                           onTap: () async {
                             final picked = await showDatePicker(
                               context: context,
                               initialDate: provider.selectedDate,
                               firstDate: DateTime(2000),
                               lastDate: DateTime(2100),
                             );
                             if (picked != null) provider.setDate(picked);
                           },
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: _buildPickerCard(
                           context,
                           icon: Icons.access_time_rounded,
                           label: 'TIME',
                           value: DateFormat('hh:mm a').format(provider.selectedDate),
                           onTap: () async {
                             final picked = await showTimePicker(
                               context: context,
                               initialTime: TimeOfDay.fromDateTime(provider.selectedDate),
                             );
                             if (picked != null) provider.setTime(picked);
                           },
                         ),
                       ),
                     ],
                   ),

                   const SizedBox(height: 16),
                   // Account Dropdown
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                     decoration: BoxDecoration(
                       color: isDark ? theme.cardColor : const Color(0xFFF8F9FA),
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: DropdownButtonHideUnderline(
                       child: DropdownButton<String>(
                         value: provider.selectedAccountId,
                         dropdownColor: theme.cardColor,
                         hint: Row(
                           children: [
                             Container(
                               padding: const EdgeInsets.all(8),
                               decoration: BoxDecoration(
                                 color: Colors.green.withOpacity(0.1),
                                 shape: BoxShape.circle,
                               ),
                               child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 18),
                             ),
                             const SizedBox(width: 12),
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Text('ACCOUNT', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                                 const SizedBox(height: 2),
                                 Text('Select Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                               ],
                             ),
                           ],
                         ),
                         isExpanded: true,
                         icon: Icon(Icons.unfold_more_rounded, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                         items: provider.accounts.map((e) => DropdownMenuItem(
                           value: e.id,
                           child: Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: Colors.green.withOpacity(0.1),
                                   shape: BoxShape.circle,
                                 ),
                                 child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 18),
                               ),
                               const SizedBox(width: 12),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text('ACCOUNT', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                                   const SizedBox(height: 2),
                                   Text(e.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.onSurface)),
                                 ],
                               ),
                             ],
                           ),
                         )).toList(),
                         onChanged: (v) {
                           if (v != null) provider.setAccount(v);
                         },
                       ),
                     ),
                   ),

                   const SizedBox(height: 16),
                   // Note Field
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: isDark ? theme.cardColor : const Color(0xFFF8F9FA),
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           children: [
                             Icon(Icons.notes_rounded, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                             const SizedBox(width: 8),
                             Text('NOTE (OPTIONAL)', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600)),
                           ],
                         ),
                         TextField(
                           onChanged: provider.updateNote,
                           style: TextStyle(color: theme.colorScheme.onSurface),
                           decoration: InputDecoration(
                             hintText: 'Add a description for this expense...',
                             hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                             border: InputBorder.none,
                             contentPadding: const EdgeInsets.only(top: 8),
                           ),
                           maxLines: 2,
                           minLines: 1,
                         ),
                       ],
                     ),
                   ),
                    const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          
          // Keypad and Save Section
          Container(
            color: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8F9FA), // Slightly different bg for keypad area
            child: Column(
              children: [
                // Custom Keypad
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  childAspectRatio: 1.3,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildKey(context, 'C', provider, isOp: true), _buildKey(context, '÷', provider, isOp: true), _buildKey(context, '×', provider, isOp: true), _buildKey(context, '⌫', provider, isOp: true),
                    _buildKey(context, '7', provider), _buildKey(context, '8', provider), _buildKey(context, '9', provider), _buildKey(context, '-', provider, isOp: true),
                    _buildKey(context, '4', provider), _buildKey(context, '5', provider), _buildKey(context, '6', provider), _buildKey(context, '+', provider, isOp: true),
                    _buildKey(context, '1', provider), _buildKey(context, '2', provider), _buildKey(context, '3', provider), _buildKey(context, '=', provider, isOp: true),
                    _buildKey(context, '%', provider, isOp: true), _buildKey(context, '0', provider), _buildKey(context, '.', provider), 
                    // Empty placeholder or check mark
                     Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: provider.isValid ? () {
                         provider.saveExpense().then((success) {
                           if (context.mounted) {
                             if (success) {
                               Navigator.pop(context);
                             } else {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Failed to save expense.')),
                               );
                             }
                           }
                         });
                        } : null,
                        borderRadius: BorderRadius.circular(16),
                        child: const Center(child: Icon(Icons.check, color: Colors.white, size: 28)),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(BuildContext context, String label, AddExpenseProvider provider, {bool isOp = false}) {
    final isBack = label == '⌫';
    final isClear = label == 'C';
    final isEquals = label == '=';
    final theme = Theme.of(context);
    
    Color bgColor;
    Color textColor;
    
    if (isEquals) {
      bgColor = AppColors.primary.withOpacity(0.1);
      textColor = AppColors.primary;
    } else if (isOp || isClear || isBack) {
      bgColor = theme.brightness == Brightness.dark ? Colors.grey.withOpacity(0.1) : Colors.grey.shade200;
      textColor = isOp ? AppColors.primary : theme.colorScheme.onSurface;
    } else {
      bgColor = Colors.transparent;
      textColor = theme.colorScheme.onSurface;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          if (isBack) {
            provider.onKeyPress('backspace');
          } else {
             provider.onKeyPress(label);
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: isBack 
            ? Icon(Icons.backspace_outlined, size: 20, color: textColor)
            : Text(
                label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
        Text(action, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildPickerCard(BuildContext context, {required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surface : const Color(0xFFE0E2E5), // Light grey for icon bg
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.onSurface)),
              ],
            )
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('food') || lower.contains('restaurant')) return Icons.restaurant;
    if (lower.contains('travel') || lower.contains('transport') || lower.contains('fuel')) return Icons.directions_car;
    if (lower.contains('shop') || lower.contains('grocery') || lower.contains('buy')) return Icons.shopping_cart;
    if (lower.contains('bill') || lower.contains('utility') || lower.contains('rent')) return Icons.receipt;
    if (lower.contains('fun') || lower.contains('game') || lower.contains('movie')) return Icons.sports_esports;
    if (lower.contains('health') || lower.contains('medical') || lower.contains('doctor')) return Icons.medical_services;
    if (lower.contains('edu') || lower.contains('school')) return Icons.school;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center;
    if (lower.contains('salary') || lower.contains('income')) return Icons.attach_money;
    return Icons.category;
  }
}
