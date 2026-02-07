import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/presentation/state/auth_form_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFormProvider(),
      child: const _SignupView(),
    );
  }
}

class _SignupView extends StatelessWidget {
  const _SignupView();

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
         elevation: 0,
         leading: IconButton(
           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
           onPressed: () => Navigator.pop(context),
         ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 32),
              const Center(child: Text("Create an account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black))),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Start your journey to financial freedom\ntoday.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF4CAF50), height: 1.5),
                ),
              ),
              const SizedBox(height: 40),
              AuthTextField(
                label: "Full Name",
                hint: "John Doe",
                prefixIcon: Icons.person_outline,
                onChanged: formProvider.setSignupName,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: "Email Address",
                hint: "name@example.com",
                prefixIcon: Icons.email_outlined,
                onChanged: formProvider.setSignupEmail,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: "Password",
                hint: "Create a password",
                prefixIcon: Icons.lock_outline,
                obscureText: formProvider.signupObscureText,
                onToggleObscure: formProvider.toggleSignupObscure,
                onChanged: formProvider.setSignupPassword,
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: "Confirm Password",
                hint: "Repeat password",
                prefixIcon: Icons.lock_outline,
                obscureText: formProvider.signupConfirmObscureText,
                onToggleObscure: formProvider.toggleSignupConfirmObscure,
                onChanged: formProvider.setSignupConfirmPassword,
                errorText: (formProvider.signupConfirmPassword.isNotEmpty && formProvider.signupPassword != formProvider.signupConfirmPassword) 
                           ? "Passwords do not match" : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (formProvider.isSignupValid && authProvider.status != AuthStatus.authenticating)
                      ? () async {
                          await authProvider.signUp(
                            formProvider.signupEmail,
                            formProvider.signupPassword,
                            formProvider.signupName,
                          );
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
                            Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Text("Already have an account? ", style: TextStyle(color: Colors.grey.shade600)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text("Log in", style: TextStyle(color: Color(0xFF32D74B), fontWeight: FontWeight.bold)),
                  )
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
