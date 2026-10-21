import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import 'main_nav_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;
  final String serviceTitle;
  final String bookingDate;
  final String timeSlot;
  final String address;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingData,
    required this.serviceTitle,
    required this.bookingDate,
    required this.timeSlot,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final bookingNumber = bookingData['bookingNumber']?.toString() ?? 'JS-ORD';
    final serviceOtp = bookingData['serviceOtp']?.toString() ?? '1234';
    final totalAmount = (bookingData['totalAmount'] is num)
        ? (bookingData['totalAmount'] as num).toDouble()
        : double.tryParse(bookingData['totalAmount']?.toString() ?? '0') ?? 0.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Success Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, color: AppTheme.successGreen, size: 42),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Booking #$bookingNumber',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              // 4-DIGIT DOORSTEP OTP CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, color: Color(0xFFB45309), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'DOORSTEP SECURITY OTP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // OTP Digits Box
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: serviceOtp.split('').map((digit) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 48,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              digit,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Share this 4-digit OTP with your service technician ONLY after they arrive at your location to begin work.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF78350F),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Details Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    ),
                    const Divider(height: 20),
                    _InfoRow(label: 'Service', value: serviceTitle),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Date & Time', value: '$bookingDate • $timeSlot'),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Address', value: address),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Total Amount', value: '₹${totalAmount.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Actions
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerMainNavScreen(initialIndex: 2)),
                      (route) => false,
                    );
                  },
                  child: const Text('View in My Bookings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const CustomerMainNavScreen(initialIndex: 0)),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMedium)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }
}
