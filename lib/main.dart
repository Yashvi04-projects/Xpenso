import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/theme_provider.dart';

// REPOSITORIES
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/data/repositories/firebase_expense_repository.dart';
import 'features/expenses/data/datasources/firebase_expense_datasource.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/data/repositories/firestore_category_repository.dart';
import 'features/accounts/domain/repositories/account_repository.dart';
import 'features/accounts/data/repositories/firestore_account_repository.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/data/repositories/firestore_settings_repository.dart';
import 'features/expenses/domain/services/expense_service.dart';

// PROVIDERS
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/accounts/presentation/providers/accounts_provider.dart';
import 'features/categories/presentation/providers/categories_provider.dart';
import 'core/notifications/notification_service.dart';

// PAGES (For AuthWrapper)
import 'features/main_navigation/presentation/pages/main_navigation_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';

// IMPORT GENERATED OPTIONS (User must run 'flutterfire configure')
import 'firebase_options.dart';

// NOTIFICATIONS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and Notifications in parallel
  // Initialize Notifications
  final notificationService = NotificationService();
  
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    notificationService.init(),
  ]);
  
  // Schedule Daily Reminder (9:00 PM) - Non-blocking
  notificationService.scheduleDailyReminder(
    id: 1,
    hour: 21,
    minute: 0,
  );

  runApp(XpensoApp(notificationService: notificationService));
}

class XpensoApp extends StatelessWidget {
  final NotificationService notificationService;
  const XpensoApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    // Singletons for DataSources
    final authDataSource = FirebaseAuthDataSource();
    final expenseDataSource = FirebaseExpenseDataSource();

    return MultiProvider(
      providers: [
        // Theme Provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // Notification Service (Already initialized in main, just providing it)
        Provider<NotificationService>.value(value: notificationService),

        // Repositories - Auth first because others depend on it
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepositoryImpl(authDataSource),
        ),
        ProxyProvider<AuthRepository, ExpenseRepository>(
          update: (_, auth, __) => FirebaseExpenseRepositoryImpl(expenseDataSource, auth),
        ),
        
        ProxyProvider<AuthRepository, AccountRepository>(
          update: (_, auth, __) => FirestoreAccountRepository(auth),
        ),
        ProxyProvider<AuthRepository, CategoryRepository>(
          update: (_, auth, __) => FirestoreCategoryRepository(auth),
        ),
        ProxyProvider<AuthRepository, SettingsRepository>(
          update: (_, auth, __) => FirestoreSettingsRepository(auth),
        ),


        
        // Auth Provider
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            Provider.of<AuthRepository>(context, listen: false),
          ),
        ),

        // Expense Service (Depends on Repositories and NotificationService)
        ProxyProvider4<ExpenseRepository, CategoryRepository, AccountRepository, AuthRepository, ExpenseService>(
          update: (_, expenseRepo, catRepo, accRepo, auth, __) {
            final service = ExpenseService(expenseRepo, catRepo, accRepo, notificationService);
            // Schedule monthly summary if user is logged in
            if (auth.currentUser != null) {
              service.scheduleMonthlySummary();
            }
            return service;
          },
        ),

        // Accounts Provider
        ChangeNotifierProxyProvider<AccountRepository, AccountsProvider>(
          create: (context) => AccountsProvider(
            Provider.of<AccountRepository>(context, listen: false),
          ),
          update: (_, repo, previous) => AccountsProvider(repo),
        ),

        // Categories Provider
        ChangeNotifierProxyProvider2<CategoryRepository, ExpenseRepository, CategoriesProvider>(
          create: (context) => CategoriesProvider(
            Provider.of<CategoryRepository>(context, listen: false),
            Provider.of<ExpenseRepository>(context, listen: false),
          ),
          update: (_, catRepo, expRepo, previous) => CategoriesProvider(catRepo, expRepo),
        ),

        // Settings Provider
        ChangeNotifierProxyProvider6<SettingsRepository, ExpenseRepository, AccountRepository, CategoryRepository, ThemeProvider, NotificationService, SettingsProvider>(
          create: (context) => SettingsProvider(
            Provider.of<SettingsRepository>(context, listen: false),
            Provider.of<ExpenseRepository>(context, listen: false),
            Provider.of<AccountRepository>(context, listen: false),
            Provider.of<CategoryRepository>(context, listen: false),
            Provider.of<NotificationService>(context, listen: false),
            Provider.of<ThemeProvider>(context, listen: false),
          ),
          update: (_, settingsRepo, expRepo, accRepo, catRepo, themeProvider, notifService, previous) => 
            SettingsProvider(settingsRepo, expRepo, accRepo, catRepo, notifService, themeProvider),
        ),

        // Dashboard Provider
        ChangeNotifierProxyProvider4<ExpenseRepository, AccountRepository, SettingsRepository, NotificationService, DashboardProvider>(
          create: (context) => DashboardProvider(
            Provider.of<ExpenseRepository>(context, listen: false),
            Provider.of<AccountRepository>(context, listen: false),
            Provider.of<SettingsRepository>(context, listen: false),
            Provider.of<NotificationService>(context, listen: false),
          ),
          update: (_, expRepo, accRepo, settingsRepo, notifService, previous) => 
            DashboardProvider(expRepo, accRepo, settingsRepo, notifService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashPage(),
              '/': (context) => const AuthWrapper(),
            },
            onGenerateRoute: AppRoutes.onGenerateRoute,
            debugShowCheckedModeBanner: false,
            // Wrap in an Auth Listener for redirection
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    // Automatic Redirection Logic
    if (authProvider.status == AuthStatus.authenticated) {
      return const MainNavigationPage(); // Import this properly or use Navigator
    } else {
      return const LoginPage(); // Import properly
    }
  }
}
