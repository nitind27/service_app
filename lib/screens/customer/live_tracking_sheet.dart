import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/booking_model.dart';
import '../../config/app_theme.dart';
import '../chat/booking_chat_screen.dart';

class LiveTrackingSheet extends StatelessWidget {
  final BookingModel booking;
  const LiveTrackingSheet({super.key, required this.booking});

  static void show(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiveTrackingSheet(booking: booking),
    );
  }

  void _callTechnician(String? phone) async {
    final number = phone ?? '9876543210';
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = booking.bookingStatus == 'completed';
    final isInProgress = booking.bookingStatus == 'in_progress';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.navigation_rounded, color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Live Doorstep Tracking',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booking #${booking.bookingNumber} • ${booking.serviceTitle}',
                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textMedium),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Simulated GPS ETA Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isDone ? 'JOB COMPLETED' : (isInProgress ? 'WORK IN PROGRESS' : 'TECHNICIAN EN ROUTE'),
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              isDone ? 'Completed' : (isInProgress ? 'Active' : 'ETA: ~18 mins'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.two_wheeler_rounded, color: Color(0xFFFDBA74), size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDone
                                        ? 'Service Completed & Inspected'
                                        : (isInProgress ? 'Technician is currently working on site' : 'Arriving at your doorstep soon'),
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.addressSnapshot,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Technician Profile Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryBlue,
                          child: Text(
                            booking.providerName != null && booking.providerName!.isNotEmpty
                                ? booking.providerName![0].toUpperCase()
                                : 'P',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.providerName ?? 'Certified Service Partner',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.textDark),
                              ),
                              const SizedBox(height: 2),
                              const Row(
                                children: [
                                  Icon(Icons.star_rounded, size: 14, color: AppTheme.warningAmber),
                                  SizedBox(width: 2),
                                  Text('4.94 (280+ jobs)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                                  SizedBox(width: 8),
                                  Icon(Icons.verified_user_rounded, size: 14, color: AppTheme.successGreen),
                                  SizedBox(width: 2),
                                  Text('Verified', style: TextStyle(fontSize: 11.5, color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Call & Chat
                        IconButton(
                          icon: const Icon(Icons.phone_rounded, color: AppTheme.successGreen),
                          tooltip: 'Call Technician',
                          onPressed: () => _callTechnician(booking.providerMobile),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryBlue),
                          tooltip: 'Live Chat',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingChatScreen(
                                  bookingId: booking.id,
                                  bookingNumber: booking.bookingNumber,
                                  serviceTitle: booking.serviceTitle,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Doorstep OTP Card (Golden Box)
                  if (!isDone)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: Color(0xFFB45309), size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Doorstep Security OTP',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Tell this code to technician ONLY when they reach your doorstep.',
                                  style: TextStyle(fontSize: 11, color: Color(0xFF78350F)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                            ),
                            child: Text(
                              booking.serviceOtp,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Progress Timeline Stepper
                  const Text('Service Delivery Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                  const SizedBox(height: 14),

                  _TimelineStep(
                    title: 'Booking Placed & Confirmed',
                    subtitle: 'Order #${booking.bookingNumber} confirmed with verified guarantee',
                    isFinished: true,
                    isCurrent: false,
                  ),
                  _TimelineStep(
                    title: 'Technician Assigned',
                    subtitle: 'Equipment & sanitized toolkit packed for transit',
                    isFinished: true,
                    isCurrent: false,
                  ),
                  _TimelineStep(
                    title: 'En Route to Doorstep',
                    subtitle: 'Technician heading to your address (${booking.timeSlot})',
                    isFinished: isInProgress || isDone,
                    isCurrent: !isInProgress && !isDone,
                  ),
                  _TimelineStep(
                    title: 'Doorstep OTP Verification & Work',
                    subtitle: 'Service started under standard safety protocols',
                    isFinished: isDone,
                    isCurrent: isInProgress,
                  ),
                  _TimelineStep(
                    title: 'Work Completed & 30-Day Guarantee',
                    subtitle: 'Free rework warranty and invoice generated',
                    isFinished: isDone,
                    isCurrent: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isFinished;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.isFinished,
    required this.isCurrent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor = const Color(0xFFCBD5E1);
    if (isFinished) dotColor = AppTheme.successGreen;
    if (isCurrent) dotColor = AppTheme.primaryBlue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: dotColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: Center(
                child: isFinished
                    ? const Icon(Icons.check, size: 12, color: AppTheme.successGreen)
                    : Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isFinished ? AppTheme.successGreen.withOpacity(0.5) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: isCurrent ? AppTheme.primaryBlue : (isFinished ? AppTheme.textDark : AppTheme.textMedium),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
