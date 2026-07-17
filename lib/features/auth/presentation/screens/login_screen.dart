import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../../../../core/base/base_stateful_screen.dart';

class LoginScreen extends BaseStatefulScreen<AuthState> {
  const LoginScreen({super.key});

  @override
  BaseScreenState<LoginScreen, AuthState> createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseScreenState<LoginScreen, AuthState> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  dynamic get provider => authNotifierProvider;

  @override
  Widget body(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final notifier = ref.read(authNotifierProvider.notifier);

    ref.listen<AuthState>(authNotifierProvider, (previous, current) {
      if (current.emailOrPhone != _emailController.text) {
        _emailController.text = current.emailOrPhone;
      }
      if (current.password != _passwordController.text) {
        _passwordController.text = current.password;
      }
      if (current.user != null && previous?.user == null) {
        // Navigate to dashboard/home screen
      }
    });

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.blueAccent],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white.withValues(alpha: 0.96),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_person,
                        size: 64,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.indigo,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to access your business store',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Email/Phone Field
                      TextField(
                        controller: _emailController,
                        onChanged: notifier.updateEmailOrPhone,
                        decoration: InputDecoration(
                          labelText: 'Email or Phone Number',
                          errorText: state.emailOrPhoneError,
                          prefixIcon: const Icon(Icons.person, color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        onChanged: notifier.updatePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: state.passwordError,
                          prefixIcon: const Icon(Icons.lock, color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Remember Me Row
                      Row(
                        children: [
                          Checkbox(
                            value: state.isRememberMe,
                            activeColor: Colors.indigo,
                            onChanged: (val) {
                              notifier.toggleRememberMe(val);
                            },
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(fontSize: 14, color: Colors.indigo),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Forget password flow
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      ElevatedButton(
                        onPressed: (state.isFormValid && !state.isLoading)
                            ? () => notifier.submitLogin()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      );
  }
}
