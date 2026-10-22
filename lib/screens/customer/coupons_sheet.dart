import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/app_theme.dart';

class CouponsSheet extends StatefulWidget {
  final Function(String code) onSelectCoupon;
  const CouponsSheet({super.key, required this.onSelectCoupon});

  static void show(BuildContext context, {required Function(String) onSelect}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CouponsSheet(onSelectCoupon: onSelect),
    );
  }

  @override
  State<CouponsSheet> createState() => _CouponsSheetState();
}

class _CouponsSheetState extends State<CouponsSheet> {
  final ApiService _api = ApiService();
  List<dynamic> _coupons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    try {
      final res = await _api.get('/coupons');
      if (res.success && res.data != null && res.data['coupons'] != null) {
        setState(() {
          _coupons = res.data['coupons'] as List;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
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
                const Row(
                  children: [
                    Icon(Icons.local_offer_rounded, color: AppTheme.accentOrange, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Available Coupons & Offers',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textDark),
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _coupons.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_offer_outlined, size: 48, color: AppTheme.textLight),
                            const SizedBox(height: 10),
                            const Text('No coupons available right now', style: TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _coupons.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, idx) {
                          final c = _coupons[idx];
                          final code = c['code']?.toString() ?? 'SAVE';
                          final title = c['title']?.toString() ?? 'Special Discount';
                          final isPercent = c['discount_type'] == 'percentage';
                          final discountVal = c['discount_value']?.toString() ?? '10';
                          final minAmount = c['min_booking_amount']?.toString() ?? '0';

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFDBA74)),
                                  ),
                                  child: const Icon(Icons.confirmation_num_outlined, color: AppTheme.accentOrange, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppTheme.primaryBlue, width: 1.2),
                                            ),
                                            child: Text(
                                              code,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 0.8,
                                                color: AppTheme.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isPercent ? '$discountVal% OFF' : 'Flat ₹$discountVal OFF',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.successGreen),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                                      Text('Min order ₹$minAmount', style: const TextStyle(fontSize: 11, color: AppTheme.textMedium)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    widget.onSelectCoupon(code);
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    backgroundColor: AppTheme.primaryBlue,
                                  ),
                                  child: const Text('APPLY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
