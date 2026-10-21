import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../config/app_theme.dart';

class ProviderOtpDialog extends StatefulWidget {
  final int bookingId;
  final String bookingNumber;
  final String customerName;

  const ProviderOtpDialog({
    super.key,
    required this.bookingId,
    required this.bookingNumber,
    required this.customerName,
  });

  @override
  State<ProviderOtpDialog> createState() => _ProviderOtpDialogState();
}

class _ProviderOtpDialogState extends State<ProviderOtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit code provided by the customer')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.startJobWithOtp(widget.bookingId, otp);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doorstep OTP verified! Job is now In Progress.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Invalid Doorstep OTP!'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.lock_clock_rounded, color: AppTheme.primaryBlue),
          SizedBox(width: 8),
          Text('Verify Doorstep OTP', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ask customer "${widget.customerName}" for their 4-digit Doorstep Security OTP before commencing service for booking #${widget.bookingNumber}.',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
                color: AppTheme.primaryBlue,
              ),
              decoration: const InputDecoration(
                hintText: '••••',
                counterText: '',
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _verifyOtp,
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Verify & Start Job'),
        ),
      ],
    );
  }
}
