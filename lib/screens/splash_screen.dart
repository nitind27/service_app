import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/service_provider.dart';
import '../config/app_theme.dart';
import 'customer/main_nav_screen.dart';
import 'provider/provider_main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final services = context.read<ServiceCatalogProvider>();

    await Future.wait([
      auth.checkAuthState(),
      services.fetchCategories(),
      services.fetchServices(),
      Future.delayed(const Duration(milliseconds: 1400)),
    ]);

    if (!mounted) return;

    if (auth.isAuthenticated && auth.isProvider) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProviderMainNavScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CustomerMainNavScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo Icon
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.handshake_rounded,
                  size: 48,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            const Text(
              'JeevanSeva',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Life Services • From Birth to Beyond',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFDBA74),
                ),
              ),
            ),
            const SizedBox(height: 48),
            // Loader
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
