import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../chat/booking_chat_screen.dart';
import 'provider_otp_dialog.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _callCustomer(String mobile) async {
    final uri = Uri.parse('tel:$mobile');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openOtpDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => ProviderOtpDialog(
        bookingId: booking.id,
        bookingNumber: booking.bookingNumber,
        customerName: booking.customerName,
      ),
    );
  }

  void _completeJob(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Service Job?'),
        content: Text('Are you sure you want to mark booking #${booking.bookingNumber} as completed? Your 85% payout will be added to earnings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
            child: const Text('Complete Job'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context.read<BookingProvider>().completeJob(booking.id);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job completed! Earnings updated.'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to complete job')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final assignedJobs = bookingProvider.bookings
        .where((b) => b.bookingStatus == 'assigned' || b.bookingStatus == 'confirmed' || b.bookingStatus == 'pending')
        .toList();
    final inProgressJobs = bookingProvider.bookings
        .where((b) => b.bookingStatus == 'in_progress')
        .toList();
    final completedJobs = bookingProvider.bookings
        .where((b) => b.bookingStatus == 'completed')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(auth.user?.name ?? 'Partner Dashboard', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            Text(auth.user?.city ?? 'India', style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
          ],
        ),
        actions: [
          // Online Toggle Switch
          Row(
            children: [
              Text(
                _isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _isOnline ? AppTheme.successGreen : AppTheme.dangerRed,
                ),
              ),
              Switch(
                value: _isOnline,
                activeColor: AppTheme.successGreen,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textMedium,
          indicatorColor: AppTheme.primaryBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: 'To Do (${assignedJobs.length})'),
            Tab(text: 'In Progress (${inProgressJobs.length})'),
            Tab(text: 'Done (${completedJobs.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => bookingProvider.fetchBookings(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildJobsList(assignedJobs, isPending: true),
            _buildJobsList(inProgressJobs, isInProgress: true),
            _buildJobsList(completedJobs, isCompleted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(List<BookingModel> jobs, {bool isPending = false, bool isInProgress = false, bool isCompleted = false}) {
    if (jobs.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.assignment_turned_in_outlined, size: 56, color: AppTheme.textLight),
                SizedBox(height: 12),
                Text('No jobs in this category right now', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: jobs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, idx) {
        final b = jobs[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('#${b.bookingNumber}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryBlue)),
                  StatusBadge(status: b.bookingStatus),
                ],
              ),
              const Divider(height: 16),
              // Service Title
              Text(b.serviceTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 8),
              // Customer info & call
              Row(
                children: [
                  const Icon(Icons.person_pin_circle_rounded, size: 16, color: AppTheme.primaryBlue),
                  const SizedBox(width: 6),
                  Text('${b.customerName} (${b.customerMobile})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.phone_in_talk_rounded, color: AppTheme.successGreen, size: 20),
                    tooltip: 'Call Customer',
                    onPressed: () => _callCustomer(b.customerMobile),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                    tooltip: 'In-App Chat',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingChatScreen(
                            bookingId: b.id,
                            bookingNumber: b.bookingNumber,
                            serviceTitle: b.serviceTitle,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Address & Slot
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textMedium),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(b.addressSnapshot, style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textMedium),
                  const SizedBox(width: 6),
                  Text('${b.bookingDate} • ${b.timeSlot}', style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                ],
              ),
              const SizedBox(height: 14),
              // Actions
              if (isPending)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _openOtpDialog(b),
                    icon: const Icon(Icons.security_rounded, size: 18),
                    label: const Text('Start Job (Verify Doorstep OTP)', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                  ),
                )
              else if (isInProgress)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () => _completeJob(b),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    label: const Text('Mark Service Completed', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                  ),
                )
              else if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '✓ Service Delivered & Closed',
                    style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
