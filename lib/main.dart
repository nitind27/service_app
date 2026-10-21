import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api_constants.dart';
import 'config/app_theme.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/service_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/payout_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage-backed configurations
  await ApiConstants.init();
  await ApiService().init();

  runApp(const JeevanSevaApp());
}

class JeevanSevaApp extends StatelessWidget {
  const JeevanSevaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ServiceCatalogProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => PayoutProvider()),
      ],
      child: MaterialApp(
        title: 'JeevanSeva - All-in-One Life Services Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
