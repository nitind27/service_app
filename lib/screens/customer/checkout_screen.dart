import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../config/app_theme.dart';
import '../../config/price_formatter.dart';
import 'booking_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final ServiceModel service;
  final ServiceVariant? selectedVariant;

  const CheckoutScreen({
    super.key,
    required this.service,
    this.selectedVariant,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  String _selectedTimeSlot = '10:00 AM - 12:00 PM';
  final List<String> _timeSlots = [
    '08:00 AM - 10:00 AM',
    '10:00 AM - 12:00 PM',
    '01:00 PM - 03:00 PM',
    '03:00 PM - 05:00 PM',
    '05:00 PM - 07:00 PM',
  ];

  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _addressController;
  late TextEditingController _instructionsController;

  bool _useWallet = false;
  String _paymentMode = 'cod'; // 'cod' or 'cashfree'

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));

    final auth = context.read<AuthProvider>();
    final loc = context.read<LocationProvider>();

    _nameController = TextEditingController(text: auth.user?.name ?? '');
    _mobileController = TextEditingController(text: auth.user?.mobile ?? '');
    _addressController = TextEditingController(
      text: 'Flat 402, Green Valley Apartments, ${loc.city}, PIN: ${loc.pincode}',
    );
    _instructionsController = TextEditingController();

    // Fetch user wallet balance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().fetchWallet();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final bookingProvider = context.read<BookingProvider>();
    final auth = context.read<AuthProvider>();

    final res = await bookingProvider.createBooking(
      serviceId: widget.service.id,
      variantId: widget.selectedVariant?.id,
      customerName: _nameController.text.trim(),
      customerMobile: _mobileController.text.trim(),
      customerEmail: auth.user?.email,
      addressSnapshot: _addressController.text.trim(),
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
      timeSlot: _selectedTimeSlot,
      specialInstructions: _instructionsController.text.trim(),
      useWallet: _useWallet,
      paymentMode: _paymentMode,
    );

    if (!mounted) return;

    if (res != null) {
      // Refresh user to sync wallet balance if used
      if (_useWallet) {
        auth.refreshUser();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            bookingData: res,
            serviceTitle: widget.service.title,
            bookingDate: DateFormat('dd MMM yyyy').format(_selectedDate),
            timeSlot: _selectedTimeSlot,
            address: _addressController.text.trim(),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Booking failed'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final bookingProvider = context.watch<BookingProvider>();

    final basePrice = widget.selectedVariant != null
        ? widget.selectedVariant!.price
        : widget.service.effectivePrice;

    final tax = (basePrice * 0.05);
    const convenienceFee = 49.0;
    final grossTotal = basePrice + tax + convenienceFee;

    double walletDeduction = 0.0;
    if (_useWallet && wallet.balance > 0) {
      walletDeduction = wallet.balance >= grossTotal ? grossTotal : wallet.balance;
    }
    final netPayable = grossTotal - walletDeduction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Doorstep Service', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected Service Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.handyman_rounded, color: AppTheme.primaryBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service.title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.selectedVariant != null)
                            Text(
                              'Package: ${widget.selectedVariant!.name}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      PriceFormatter.format(basePrice),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Section 1: Schedule
              const Text('1. Select Date & Arrival Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              // Date Picker Card
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.primaryBlue),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      const Text('Change', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Time Slot Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return ChoiceChip(
                    label: Text(slot, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedTimeSlot = slot),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              // Section 2: Doorstep Address
              const Text('2. Doorstep Service Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'House/Flat No, Apartment, Street, Landmark, PIN code',
                  prefixIcon: Icon(Icons.home_outlined, size: 20),
                ),
                validator: (val) => val == null || val.trim().length < 5 ? 'Please enter complete address' : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name',
                        isDense: true,
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Mobile (+91)',
                        isDense: true,
                        counterText: '',
                      ),
                      validator: (val) => val == null || val.trim().length != 10 ? '10 digits' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Section 3: Wallet & Payment Method
              const Text('3. Payment & Wallet Discount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              // Wallet balance toggle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _useWallet,
                      activeColor: AppTheme.successGreen,
                      onChanged: wallet.balance > 0
                          ? (val) => setState(() => _useWallet = val ?? false)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apply JeevanSeva Wallet Balance',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: wallet.balance > 0 ? const Color(0xFF166534) : AppTheme.textLight,
                            ),
                          ),
                          Text(
                            'Available Balance: ${PriceFormatter.format(wallet.balance)}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Payment modes
              if (netPayable > 0) ...[
                RadioListTile<String>(
                  value: 'cod',
                  groupValue: _paymentMode,
                  title: const Text('Cash on Delivery / Pay After Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Pay via Cash, UPI, or Card after job completion', style: TextStyle(fontSize: 12)),
                  onChanged: (val) => setState(() => _paymentMode = val!),
                ),
                RadioListTile<String>(
                  value: 'cashfree',
                  groupValue: _paymentMode,
                  title: const Text('Online Payment (Cashfree Gateway)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('UPI, Google Pay, PhonePe, Debit/Credit Card, Netbanking', style: TextStyle(fontSize: 12)),
                  onChanged: (val) => setState(() => _paymentMode = val!),
                ),
              ],
              const SizedBox(height: 20),
              // Section 4: Order Summary Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service Base Price', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                        Text(PriceFormatter.format(basePrice), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST Taxes (5%)', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                        Text(PriceFormatter.format(tax), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Doorstep Convenience Fee', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                        Text('₹49', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (walletDeduction > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Wallet Balance Applied', style: TextStyle(fontSize: 13, color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                          Text('- ${PriceFormatter.format(walletDeduction)}', style: const TextStyle(fontSize: 13, color: AppTheme.successGreen, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Net Payable', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                        Text(PriceFormatter.format(netPayable), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Submit CTA
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: bookingProvider.isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                  ),
                  child: bookingProvider.isLoading
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirm Booking & Get Security OTP', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '🔒 Safe & Encrypted • 4-Digit Security OTP protection',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
