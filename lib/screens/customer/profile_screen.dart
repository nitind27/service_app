import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/location_bottom_sheet.dart';
import '../../widgets/server_settings_dialog.dart';
import '../auth/login_screen.dart';
import '../provider/provider_main_nav_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocationProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet_rounded),
            tooltip: 'Server Settings',
            onPressed: () => ServerSettingsDialog.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Guest User',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'Sign in to access your bookings',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                        ),
                        if (user != null && user.mobile.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '+91 ${user.mobile}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu Items Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue),
                    title: const Text('Service Location', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(loc.displayText, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => LocationBottomSheet.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dns_outlined, color: AppTheme.primaryBlue),
                    title: const Text('Backend Server Settings', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Switch between localhost, emulator, Wi-Fi IP', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => ServerSettingsDialog.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.support_agent_rounded, color: AppTheme.primaryBlue),
                    title: const Text('24x7 Customer Helpline', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('1800-123-5338 (Toll Free)', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('JeevanSeva Support'),
                          content: const Text('Call toll-free: 1800-123-5338\nEmail: support@jeevanseva.in\nAvailable 24x7 across all 28 Indian States.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                          ],
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.handyman_outlined, color: AppTheme.accentOrange),
                    title: const Text('Service Partner Portal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Technician job dashboard & payouts', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      if (auth.isAuthenticated && auth.isProvider) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ProviderMainNavScreen()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen(isProviderInitial: true)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Login / Logout Action
            if (auth.isAuthenticated)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.dangerRed, size: 20),
                  label: const Text('Sign Out', style: TextStyle(color: AppTheme.dangerRed, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Sign In / Register', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'JeevanSeva Mobile App v1.0.0\nSecure • Multi-Service • India Nationwide',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppTheme.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
