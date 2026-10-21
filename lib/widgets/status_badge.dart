import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'CONFIRMED';
        break;
      case 'assigned':
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F46E5);
        label = 'ASSIGNED';
        break;
      case 'in_progress':
        bg = const Color(0xFFFAF5FF);
        fg = const Color(0xFF9333EA);
        label = 'IN PROGRESS';
        break;
      case 'completed':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        label = 'COMPLETED';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        label = 'CANCELLED';
        break;
      case 'refunded':
      case 'refund_requested':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFD97706);
        label = 'REFUNDED';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFEA580C);
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
