import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';
import '../customer/main_nav_screen.dart';
import '../provider/provider_main_nav_screen.dart';
import 'register_screen.dart';
import '../../widgets/server_settings_dialog.dart';

class LoginScreen extends StatefulWidget {
  final bool isProviderInitial;
  const LoginScreen({super.key, this.isProviderInitial = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isProviderMode = false;

  @override
  void initState() {
    super.initState();
    _isProviderMode = widget.isProviderInitial;
    _emailController = TextEditingController(
      text: _isProviderMode ? 'rajesh.provider@jeevanseva.in' : 'customer@jeevanseva.in',
    );
    _passwordController = TextEditingController(
      text: _isProviderMode ? 'Provider@123' : 'Customer@123',
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemo(bool asProvider) {
    setState(() {
      _isProviderMode = asProvider;
      if (asProvider) {
        _emailController.text = 'rajesh.provider@jeevanseva.in';
        _passwordController.text = 'Provider@123';
      } else {
        _emailController.text = 'customer@jeevanseva.in';
        _passwordController.text = 'Customer@123';
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (auth.isProvider) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProviderMainNavScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerMainNavScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed. Please check credentials.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isProviderMode ? 'Service Partner Portal' : 'Customer Sign In'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet_rounded),
            tooltip: 'Server Settings',
            onPressed: () => ServerSettingsDialog.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode switcher tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _fillDemo(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isProviderMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isProviderMode
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: !_isProviderMode ? AppTheme.primaryBlue : AppTheme.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _fillDemo(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isProviderMode ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isProviderMode
                                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Service Partner',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _isProviderMode ? AppTheme.primaryBlue : AppTheme.textMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _isProviderMode ? 'Welcome, Partner' : 'Welcome to JeevanSeva',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isProviderMode
                    ? 'Log in to manage jobs, verify OTPs, and track daily payouts'
                    : 'Access verified doorstep life services with instant booking',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                ),
              ),
              const SizedBox(height: 24),
              // Email / Mobile Input
              const Text(
                'Email or Mobile Number',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter registered email or mobile',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter email or mobile' : null,
              ),
              const SizedBox(height: 18),
              // Password Input
              const Text(
                'Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter password' : null,
              ),
              const SizedBox(height: 28),
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isProviderMode ? 'Log In as Partner' : 'Sign In as Customer'),
                ),
              ),
              const SizedBox(height: 20),
              // Quick 1-Tap Demo Buttons
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bolt_rounded, size: 18, color: AppTheme.successGreen),
                        SizedBox(width: 6),
                        Text(
                          '1-Tap Demo Test Logins',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _fillDemo(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: Color(0xFF86EFAC)),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('Customer Demo', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _fillDemo(true),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: const BorderSide(color: Color(0xFF86EFAC)),
                              backgroundColor: Colors.white,
                            ),
                            child: const Text('Partner Demo', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Register Prompt
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterScreen(initialRole: _isProviderMode ? 'provider' : 'customer'),
                      ),
                    );
                  },
                  child: Text(
                    _isProviderMode
                        ? "Want to register as a new partner? Sign Up"
                        : "Don't have an account? Sign Up",
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
