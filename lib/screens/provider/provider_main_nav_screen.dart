import 'package:flutter/material.dart';
import 'provider_home_screen.dart';
import 'provider_earnings_screen.dart';
import '../customer/profile_screen.dart';

class ProviderMainNavScreen extends StatefulWidget {
  final int initialIndex;
  const ProviderMainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<ProviderMainNavScreen> createState() => _ProviderMainNavScreenState();
}

class _ProviderMainNavScreenState extends State<ProviderMainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screens = const [
      ProviderHomeScreen(),
      ProviderEarningsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'My Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments_outlined),
            activeIcon: Icon(Icons.payments_rounded),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            activeIcon: Icon(Icons.account_circle_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
