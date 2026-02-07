import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/settings_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.onSurface;
    final subHeaderColor = theme.colorScheme.onSurface.withOpacity(0.6);
    final cardColor = theme.cardColor;
    final isDark = theme.brightness == Brightness.dark;
    final iconBgColor = isDark ? theme.colorScheme.primary.withOpacity(0.2) : const Color(0xFF386641);
    final iconColor = isDark ? theme.colorScheme.primary : Colors.white;

    if (provider.settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = provider.settings!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text("App Settings", style: TextStyle(color: headerColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("APPEARANCE", subHeaderColor),
            _buildContainer(
              color: cardColor,
              children: [
                _buildSwitchTile(
                  title: "Dark Mode",
                  icon: Icons.dark_mode,
                  value: provider.isDarkMode,
                  onChanged: (val) => provider.toggleTheme(),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
              ],
            ),

            _buildSectionHeader("PREFERENCES", subHeaderColor),
            _buildContainer(
              color: cardColor,
              children: [
                _buildNavTile(
                  title: "Monthly Budget",
                  icon: Icons.account_balance_wallet,
                  value: "${settings.currency} ${settings.monthlyBudget.toStringAsFixed(0)}",
                  onTap: () => _showBudgetDialog(context, provider),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildNavTile(
                  title: "Default Currency",
                  icon: Icons.currency_exchange,
                  value: settings.currency,
                  onTap: () => _showCurrencyDialog(context, provider),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
              ],
            ),

            _buildSectionHeader("NOTIFICATIONS", subHeaderColor),
            _buildContainer(
              color: cardColor,
              children: [
                _buildSwitchTile(
                  title: "Daily Reminders",
                  icon: Icons.notifications_active,
                  value: settings.dailyReminders,
                  onChanged: (val) => provider.toggleDailyReminders(val),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                if (settings.dailyReminders) ...[
                  Divider(height: 1, indent: 60, color: theme.dividerColor),
                  _buildNavTile(
                    title: "Reminder Time",
                    icon: Icons.access_time,
                    value: settings.reminderTime,
                    onTap: () async {
                      final timeParts = settings.reminderTime.split(':');
                      final initialTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
                      final picked = await showTimePicker(context: context, initialTime: initialTime);
                      if (picked != null) provider.updateReminderTime(picked);
                    },
                    titleColor: headerColor,
                    iconBg: iconBgColor,
                    iconColor: iconColor,
                  ),
                ],
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildSwitchTile(
                  title: "Budget Alerts",
                  icon: Icons.notification_important,
                  value: settings.budgetAlerts,
                  onChanged: (val) => provider.toggleBudgetAlerts(val),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildSwitchTile(
                  title: "Category Budgets",
                  icon: Icons.category,
                  value: settings.categoryBudgetToggle,
                  onChanged: (val) => provider.toggleCategoryBudget(val),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildNavTile(
                  title: "Notification Sound",
                  icon: Icons.volume_up,
                  value: settings.notificationSound.toUpperCase(),
                  onTap: () => _showSoundDialog(context, provider),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
              ],
            ),

            _buildSectionHeader("DATA & STORAGE", subHeaderColor),
            _buildContainer(
              color: cardColor,
              children: [
                _buildActionTile(
                  title: "Export as CSV",
                  icon: Icons.table_chart,
                  actionIcon: Icons.download,
                  onTap: () => provider.exportToCSV(),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildActionTile(
                  title: "Export as PDF",
                  icon: Icons.picture_as_pdf,
                  actionIcon: Icons.download,
                  onTap: () => provider.exportToPDF(),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildActionTile(
                  title: "Clear Local Cache",
                  icon: Icons.cleaning_services,
                  actionIcon: Icons.chevron_right,
                  onTap: () {
                    provider.clearCache();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cache cleared")));
                  },
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildActionTile(
                  title: "Reset All Data",
                  icon: Icons.delete_forever,
                  actionIcon: Icons.warning_amber_rounded,
                  onTap: () => _showResetConfirmation(context, provider),
                  titleColor: Colors.red,
                  iconBg: Colors.red.withOpacity(0.1),
                  iconColor: Colors.red,
                ),
              ],
            ),

            _buildSectionHeader("SUPPORT & INFO", subHeaderColor),
            _buildContainer(
              color: cardColor,
              children: [
                _buildNavTile(
                  title: "About Xpenso",
                  icon: Icons.info_outline,
                  value: "",
                  onTap: () => _showAboutApp(context),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                _buildNavTile(
                  title: "Privacy Policy",
                  icon: Icons.privacy_tip_outlined,
                  value: "",
                  onTap: () => _showPrivacyPolicy(context),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
                Divider(height: 1, indent: 60, color: theme.dividerColor),
                 _buildNavTile(
                  title: "Contact Support",
                  icon: Icons.mail_outline,
                  value: "",
                  onTap: () => _contactSupport(),
                  titleColor: headerColor,
                  iconBg: iconBgColor,
                  iconColor: iconColor,
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await Provider.of<AuthProvider>(context, listen: false).signOut();
                  navigator.pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: 8),
                    Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text("XPENSO V1.0.0", style: TextStyle(color: subHeaderColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text("Handcrafted for financial freedom", style: TextStyle(color: subHeaderColor.withOpacity(0.5), fontStyle: FontStyle.italic, fontSize: 10)),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, SettingsProvider provider) {
    final controller = TextEditingController(text: provider.settings!.monthlyBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Monthly Budget"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Enter Amount"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final budget = double.tryParse(controller.text);
              if (budget != null) {
                provider.updateMonthlyBudget(budget);
                Navigator.pop(context);
              }
            }, 
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showCurrencyDialog(BuildContext context, SettingsProvider provider) {
    final currencies = ["INR", "USD", "EUR", "GBP", "JPY", "CAD"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Currency"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: currencies.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(currencies[index]),
              onTap: () {
                provider.updateCurrency(currencies[index]);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showSoundDialog(BuildContext context, SettingsProvider provider) {
    final sounds = ["default", "silent"];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Notification Sound"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sounds.map((s) => ListTile(
            title: Text(s.toUpperCase()),
            onTap: () {
              provider.updateNotificationSound(s);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset All Data?"),
        content: const Text("This will permanently delete all your expenses. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              provider.resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All data reset successful")));
            }, 
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "Xpenso",
      applicationVersion: "1.0.0",
      applicationLegalese: "© 2026 Xpenso Team",
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48, color: Color(0xFF386641)),
      children: [
        const Text("Xpenso is your premium companion for managing finances with style and ease."),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildContainer({required List<Widget> children, required Color color}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color titleColor,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF386641),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String title,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required Color titleColor,
    required Color iconBg,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor))),
            if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required IconData actionIcon,
    required VoidCallback onTap,
    required Color titleColor,
    required Color iconBg,
    required Color iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: titleColor))),
            Icon(actionIcon, size: 20, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Text(
            "Your privacy is important to us. Xpenso collects data solely for the purpose of helping you manage your finances. \n\n"
            "1. Data Collection: We store your expenses, categories, and account information.\n"
            "2. Data Usage: Your data is used to generate insights and summaries.\n"
            "3. Data Security: We use secure cloud storage (Firebase) to protect your information.\n\n"
            "Developed by: Xpenso Developer Team\n"
            "Contact: support@xpenso.app",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'yashvigadhiya812@gmail.com',
      query: 'subject=Xpenso Support&body=Hello Xpenso Team,',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        debugPrint("Could not launch email");
      }
    } catch (e) {
      debugPrint("Error launching email: $e");
    }
  }
}
