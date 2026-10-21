import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/status_badge.dart';
import '../chat/booking_chat_screen.dart';
import '../auth/login_screen.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({super.key});

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated) {
        context.read<BookingProvider>().fetchBookings();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCancelDialog(BookingModel booking) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this booking? If you paid online, 100% of your amount will be instantly credited back to your JeevanSeva Wallet.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for cancellation (optional)',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Booking')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<BookingProvider>().cancelBooking(
                    booking.id,
                    reason: reasonController.text,
                  );
              if (mounted) {
                if (success) {
                  context.read<AuthProvider>().refreshUser();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled. Instant refund processed to your wallet.'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not cancel booking.'),
                      backgroundColor: AppTheme.dangerRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Bookings')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.textLight),
                const SizedBox(height: 16),
                const Text('Sign in to view your bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Track scheduled appointments, technician OTPs, and invoices.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMedium, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Sign In Now'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Service Bookings', style: TextStyle(fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textMedium,
          indicatorColor: AppTheme.primaryBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => bookingProvider.fetchBookings(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsList(bookingProvider.bookings),
            _buildBookingsList(bookingProvider.activeBookings),
            _buildBookingsList(bookingProvider.completedBookings),
            _buildBookingsList(bookingProvider.cancelledBookings),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> items) {
    if (items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(Icons.inbox_rounded, size: 56, color: AppTheme.textLight),
                SizedBox(height: 12),
                Text('No bookings found in this section', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, idx) {
        final b = items[idx];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Booking No & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${b.bookingNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryBlue),
                  ),
                  StatusBadge(status: b.bookingStatus),
                ],
              ),
              const Divider(height: 18),
              // Service Title
              Text(
                b.serviceTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textDark),
              ),
              const SizedBox(height: 6),
              // Category & Date Time
              Row(
                children: [
                  const Icon(Icons.event_rounded, size: 14, color: AppTheme.textMedium),
                  const SizedBox(width: 4),
                  Text('${b.bookingDate} • ${b.timeSlot}', style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textMedium),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      b.addressSnapshot,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                    ),
                  ),
                ],
              ),
              // OTP Banner if active
              if (b.isActive) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.pin_outlined, color: Color(0xFFB45309), size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Doorstep Start OTP:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Text(
                          b.serviceOtp,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              // Amount and Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                      Text(
                        '₹${b.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Chat Button
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryBlue),
                        tooltip: 'Chat with Technician',
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
                      // Cancel Button if active
                      if (b.isActive)
                        OutlinedButton(
                          onPressed: () => _showCancelDialog(b),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.dangerRed,
                            side: const BorderSide(color: Color(0xFFFECDD3)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
