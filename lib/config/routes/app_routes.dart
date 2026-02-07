import 'package:flutter/material.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/categories/presentation/pages/categories_page.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/insights/presentation/pages/insights_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/main_navigation/presentation/pages/main_navigation_page.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/edit_profile_page.dart';
import '../../features/accounts/presentation/pages/add_account_page.dart';

class AppRoutes {
  static const String main = '/main'; // Dashboard/Tabs
  static const String login = '/';    // Initial Route is now Login
  static const String signup = '/signup';
  
  // Independent access if needed (typically handled by navbar, but useful for deep linking)
  static const String dashboard = '/dashboard'; 
  static const String expenses = '/expenses';
  static const String addExpense = '/add_expense';
  static const String categories = '/categories';
  static const String accounts = '/accounts';
  static const String addAccount = '/add_account';
  static const String insights = '/insights';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigationPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case expenses:
        return MaterialPageRoute(builder: (_) => const ExpensesPage());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesPage());
      case accounts:
        return MaterialPageRoute(builder: (_) => const AccountsPage());
      case insights:
        return MaterialPageRoute(builder: (_) => const InsightsPage());
      case AppRoutes.settings: 
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case AppRoutes.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpensePage(),
          fullscreenDialog: true, 
        );
      case AppRoutes.addAccount:
        return MaterialPageRoute(
          builder: (_) => const AddAccountPage(),
          fullscreenDialog: true,
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        );
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfilePage(),
        );
      default:
        // Default to Login
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
