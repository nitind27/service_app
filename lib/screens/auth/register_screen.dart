import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../config/app_theme.dart';
import '../customer/main_nav_screen.dart';
import '../provider/provider_main_nav_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String initialRole;
  const RegisterScreen({super.key, this.initialRole = 'customer'});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  late String _role;
  String _selectedCity = 'New Delhi';

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      mobile: _mobileController.text,
      password: _passwordController.text,
      city: _selectedCity,
      role: _role,
      businessName: _role == 'provider' ? _businessNameController.text : null,
    );

    if (!mounted) return;

    if (success) {
      if (_role == 'provider') {
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
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocationProvider>();
    _selectedCity = loc.city;

    return Scaffold(
      appBar: AppBar(
        title: Text(_role == 'provider' ? 'Register as Service Partner' : 'Create Customer Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Segment
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Customer')),
                      selected: _role == 'customer',
                      onSelected: (val) => setState(() => _role = 'customer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Service Partner')),
                      selected: _role == 'provider',
                      onSelected: (val) => setState(() => _role = 'provider'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Full Name
              const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ramesh Kumar',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (val) => val == null || val.trim().length < 2 ? 'Enter a valid name' : null,
              ),
              const SizedBox(height: 16),
              if (_role == 'provider') ...[
                const Text('Business / Trade Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Kumar Electricals & AC Care',
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter your business name' : null,
                ),
                const SizedBox(height: 16),
              ],
              // Email
              const Text('Email Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 16),
              // Mobile
              const Text('10-Digit Mobile Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  hintText: '9876543210',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  prefixText: '+91 ',
                  counterText: '',
                ),
                validator: (val) => val == null || val.trim().length != 10 ? 'Enter valid 10-digit number' : null,
              ),
              const SizedBox(height: 16),
              // Password
              const Text('Password (min 6 characters)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Create strong password',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                ),
                validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 28),
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
                      : Text(_role == 'provider' ? 'Register Partner Profile' : 'Create Free Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
