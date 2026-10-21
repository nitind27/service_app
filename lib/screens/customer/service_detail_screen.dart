import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_theme.dart';
import 'checkout_screen.dart';
import '../auth/login_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String slug;
  const ServiceDetailScreen({super.key, required this.slug});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  ServiceModel? _service;
  bool _isLoading = true;
  ServiceVariant? _selectedVariant;

  final TextEditingController _pincodeController = TextEditingController();
  Map<String, dynamic>? _pincodeResult;
  bool _isCheckingPincode = false;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _loadService() async {
    final catalog = context.read<ServiceCatalogProvider>();
    final loc = context.read<LocationProvider>();
    _pincodeController.text = loc.pincode;

    final service = await catalog.getServiceDetail(widget.slug);
    if (mounted) {
      setState(() {
        _service = service;
        _isLoading = false;
        if (service != null && service.variants.isNotEmpty) {
          _selectedVariant = service.variants.first;
        }
      });
    }
  }

  Future<void> _checkPincode() async {
    final code = _pincodeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit PIN code (e.g. 110001, 400001)')),
      );
      return;
    }

    setState(() => _isCheckingPincode = true);
    final loc = context.read<LocationProvider>();
    final res = await loc.checkPincode(code);
    if (mounted) {
      setState(() {
        _pincodeResult = res;
        _isCheckingPincode = false;
      });
    }
  }

  void _proceedToCheckout() {
    if (_service == null) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      // Prompt user to login or continue
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          service: _service!,
          selectedVariant: _selectedVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Service not found or unavailable'),
        ),
      );
    }

    final effectivePrice = _selectedVariant != null
        ? _selectedVariant!.price
        : _service!.effectivePrice;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible Image Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlue, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _service!.thumbnail ?? 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _service!.categoryName,
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 20, color: AppTheme.warningAmber),
                          const SizedBox(width: 4),
                          Text(
                            _service!.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_service!.totalReviews > 0 ? _service!.totalReviews : 84} reviews)',
                            style: const TextStyle(color: AppTheme.textMedium, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    _service!.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Duration Pill
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppTheme.textMedium),
                      const SizedBox(width: 6),
                      Text(
                        'Standard Duration: ${_service!.durationMinutes} Minutes',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMedium, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Pincode SLA Turnaround Checker
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.local_shipping_outlined, size: 18, color: AppTheme.primaryBlue),
                            SizedBox(width: 6),
                            Text(
                              'Check Doorstep Availability & SLA',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pincodeController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: const InputDecoration(
                                  hintText: 'Enter 6-digit PIN code',
                                  isDense: true,
                                  counterText: '',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _isCheckingPincode ? null : _checkPincode,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              child: _isCheckingPincode
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Check SLA', style: TextStyle(fontSize: 13)),
                            ),
                          ],
                        ),
                        if (_pincodeResult != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _pincodeResult!['message']?.toString() ?? 'Serviceable in your area',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Variants / Packages Selector
                  if (_service!.variants.isNotEmpty) ...[
                    const Text(
                      'Choose Service Package',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _service!.variants.map((v) {
                        final isSelected = _selectedVariant?.id == v.id;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedVariant = v),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBlue : AppTheme.borderColor,
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                                        ),
                                      ),
                                      if (v.description != null && v.description!.isNotEmpty)
                                        Text(
                                          v.description!,
                                          style: const TextStyle(fontSize: 11, color: AppTheme.textMedium),
                                        ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${v.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Description
                  const Text(
                    'Service Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _service!.description.isNotEmpty
                        ? _service!.description
                        : _service!.shortDescription,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textMedium, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  // Key Inclusions & Safety Badges
                  const Text(
                    'The JeevanSeva Doorstep Promise',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  const _FeatureBullet(
                    icon: Icons.pin_outlined,
                    title: '4-Digit Doorstep Security OTP',
                    subtitle: 'Job begins only after technician enters your secret OTP at doorstep.',
                  ),
                  const SizedBox(height: 8),
                  const _FeatureBullet(
                    icon: Icons.verified_user_outlined,
                    title: '100% Background-Verified Partners',
                    subtitle: 'Government ID & police verified professionals.',
                  ),
                  const SizedBox(height: 8),
                  const _FeatureBullet(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Instant Wallet Refund Policy',
                    subtitle: 'Full 100% automated refund to wallet if service is cancelled.',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // Sticky Bottom Booking Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Payable',
                    style: TextStyle(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '₹${effectivePrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                    ),
                    child: const Text('Book Service Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
            ],
          ),
        ),
      ],
    );
  }
}
