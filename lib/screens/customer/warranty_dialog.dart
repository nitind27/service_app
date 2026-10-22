import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/app_theme.dart';

class WarrantyClaimDialog extends StatefulWidget {
  final int bookingId;
  final String bookingNumber;
  final String serviceTitle;
  final VoidCallback onClaimed;

  const WarrantyClaimDialog({
    super.key,
    required this.bookingId,
    required this.bookingNumber,
    required this.serviceTitle,
    required this.onClaimed,
  });

  static void show(BuildContext context, {
    required int bookingId,
    required String bookingNumber,
    required String serviceTitle,
    required VoidCallback onClaimed,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => WarrantyClaimDialog(
        bookingId: bookingId,
        bookingNumber: bookingNumber,
        serviceTitle: serviceTitle,
        onClaimed: onClaimed,
      ),
    );
  }

  @override
  State<WarrantyClaimDialog> createState() => _WarrantyClaimDialogState();
}

class _WarrantyClaimDialogState extends State<WarrantyClaimDialog> {
  final TextEditingController _descController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _descController.text.trim();
    if (text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue faced after service')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final res = await _api.post(
        '/bookings/${widget.bookingId}/warranty',
        {'issue_description': text},
      );

      setState(() => _isSubmitting = false);

      if (res.success && mounted) {
        Navigator.pop(context);
        widget.onClaimed();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('30-Day Free Warranty Claim approved! Zero-cost follow-up scheduled.'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: AppTheme.dangerRed),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: AppTheme.successGreen),
          SizedBox(width: 8),
          Text('30-Day Free Rework Claim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppTheme.successGreen, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '100% Free Follow-up Inspection • ₹0 Charges Guarantee',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Claiming free warranty for: ${widget.serviceTitle} (#${widget.bookingNumber})',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 12),
            const Text(
              'What issue are you facing?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Water leak re-occurred from left pipe after 2 days...',
                isDense: true,
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
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Claim Free Warranty'),
        ),
      ],
    );
  }
}
