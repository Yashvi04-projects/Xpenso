import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/presentation/state/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We still use AuthFormProvider for local form state
    return ChangeNotifierProvider(
      create: (_) => AuthFormProvider(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<AuthFormProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Show error message if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!), backgroundColor: Colors.red),
        );
        authProvider.clearError();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF32D74B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Xpenso",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF32D74B), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Icon(Icons.show_chart, color: Colors.white.withOpacity(0.5), size: 60),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Center(child: Text("Welcome back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black))),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Log in to track your expenses and manage\nyour budget",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF4CAF50), height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
              AuthTextField(
                label: "Email Address",
                hint: "name@example.com",
                prefixIcon: Icons.email_outlined,
                onChanged: formProvider.setLoginEmail,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: "Password",
                hint: "Enter your password",
                prefixIcon: Icons.lock_outline,
                obscureText: formProvider.loginObscureText,
                onToggleObscure: formProvider.toggleLoginObscure,
                onChanged: formProvider.setLoginPassword,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot?", style: TextStyle(color: Color(0xFF32D74B), fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (formProvider.isLoginValid && authProvider.status != AuthStatus.authenticating)
                      ? () async {
                          await authProvider.signIn(
                            formProvider.loginEmail,
                            formProvider.loginPassword,
                          );
                          // Redirection is handled by AuthWrapper in main.dart
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32D74B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: authProvider.status == AuthStatus.authenticating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text("Sign up", style: TextStyle(color: Color(0xFF32D74B), fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR CONTINUE WITH", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SocialLoginButton(
                      label: "",
                      icon: const Icon(Icons.android, color: Colors.amber, size: 24),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SocialLoginButton(
                      label: "iOS",
                      icon: const SizedBox.shrink(),
                      isDark: true,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
