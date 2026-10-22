import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/location_provider.dart';
import '../../providers/service_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/location_bottom_sheet.dart';
import '../../widgets/service_card.dart';
import 'service_detail_screen.dart';
import 'smart_assistant_screen.dart';
import 'emergency_sos_dialog.dart';

class CustomerHomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  const CustomerHomeScreen({super.key, required this.onNavigateTab});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _activePromoIndex = 0;

  final List<Map<String, dynamic>> _promoBanners = [
    {
      'title': 'Doorstep 4-Digit Security OTP',
      'subtitle': 'Verified Technicians • Instant 100% Wallet Refund Guarantee',
      'tag': 'SAFE & TRUSTED',
      'colors': [Color(0xFF1E3A8A), Color(0xFF2563EB)],
      'icon': Icons.shield_rounded,
      'accent': Color(0xFFFDBA74),
    },
    {
      'title': 'Flat ₹200 OFF on First Booking',
      'subtitle': 'Use coupon code JEEVAN200 at checkout on any service',
      'tag': 'WELCOME OFFER',
      'colors': [Color(0xFFEA580C), Color(0xFFF97316)],
      'icon': Icons.local_offer_rounded,
      'accent': Colors.white,
    },
    {
      'title': '24x7 Priority Emergency Care',
      'subtitle': 'Rapid Ambulance Dispatch & Dignified Last Rites Support',
      'tag': '24x7 HELPLINE',
      'colors': [Color(0xFF991B1B), Color(0xFFDC2626)],
      'icon': Icons.emergency_rounded,
      'accent': Color(0xFFFECDD3),
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = context.read<LocationProvider>();
      context.read<ServiceCatalogProvider>().fetchServices(city: loc.city);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final loc = context.read<LocationProvider>();
    context.read<ServiceCatalogProvider>().fetchServices(city: loc.city, query: query);
  }

  void _callHelpline(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Get matching category style
  Map<String, dynamic> _getCategoryStyle(String name) {
    final n = name.toLowerCase();
    if (n.contains('home') || n.contains('clean') || n.contains('plumb')) {
      return {'icon': Icons.cleaning_services_rounded, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)};
    } else if (n.contains('furniture') || n.contains('carpenter')) {
      return {'icon': Icons.chair_rounded, 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7)};
    } else if (n.contains('personal') || n.contains('doctor') || n.contains('health') || n.contains('nurse')) {
      return {'icon': Icons.medical_services_rounded, 'color': const Color(0xFF059669), 'bg': const Color(0xFFECFDF5)};
    } else if (n.contains('education') || n.contains('tutor')) {
      return {'icon': Icons.school_rounded, 'color': const Color(0xFF7C3AED), 'bg': const Color(0xFFF5F3FF)};
    } else if (n.contains('wedding') || n.contains('event')) {
      return {'icon': Icons.celebration_rounded, 'color': const Color(0xFFDB2777), 'bg': const Color(0xFFFDF2F8)};
    } else if (n.contains('travel') || n.contains('vehicle') || n.contains('car')) {
      return {'icon': Icons.directions_car_rounded, 'color': const Color(0xFF0284C7), 'bg': const Color(0xFFF0F9FF)};
    } else if (n.contains('legal') || n.contains('finance') || n.contains('tax')) {
      return {'icon': Icons.gavel_rounded, 'color': const Color(0xFF4F46E5), 'bg': const Color(0xFFEEF2FF)};
    } else if (n.contains('beauty') || n.contains('salon') || n.contains('spa')) {
      return {'icon': Icons.spa_rounded, 'color': const Color(0xFF9333EA), 'bg': const Color(0xFFFAF5FF)};
    } else if (n.contains('agri') || n.contains('business')) {
      return {'icon': Icons.agriculture_rounded, 'color': const Color(0xFF0D9488), 'bg': const Color(0xFFF0FDFA)};
    } else if (n.contains('death') || n.contains('cremation') || n.contains('rites')) {
      return {'icon': Icons.favorite_border_rounded, 'color': const Color(0xFF475569), 'bg': const Color(0xFFF8FAFC)};
    }
    return {'icon': Icons.grid_view_rounded, 'color': AppTheme.primaryBlue, 'bg': const Color(0xFFEFF6FF)};
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final servicesCatalog = context.watch<ServiceCatalogProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.handshake_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
                const Text(
                  'JeevanSeva',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.primaryBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'INDIA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            GestureDetector(
              onTap: () => LocationBottomSheet.show(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.accentOrange),
                  const SizedBox(width: 3),
                  Text(
                    loc.displayText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 24x7 Helpline Hotline Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Icon(Icons.headset_mic_rounded, color: AppTheme.primaryBlue, size: 17),
            ),
            tooltip: '24x7 Helpline',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.support_agent_rounded, color: AppTheme.primaryBlue),
                      SizedBox(width: 8),
                      Text('24x7 Support Helpline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Toll-Free Customer Care:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('1800-123-5338', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                          TextButton(onPressed: () => _callHelpline('18001235338'), child: const Text('Call Now')),
                        ],
                      ),
                      const Divider(height: 16),
                      const Text('Emergency Ambulance & Last Rites:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('+91 98765 43210', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                          TextButton(onPressed: () => _callHelpline('+919876543210'), child: const Text('Urgent Call', style: TextStyle(color: Color(0xFFDC2626)))),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await servicesCatalog.fetchCategories();
          await servicesCatalog.fetchServices(city: loc.city);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search AC repair, doctor, cleaning, pandit...',
                    hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Innovation Highlights (AI Diagnostic & Emergency SOS)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SmartAssistantScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withOpacity(0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 20),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Jeevan Mitra',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: const Text('AI', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.black)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Diagnose Problem',
                                    style: TextStyle(color: Color(0xFFBFDBFE), fontSize: 10.5, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        EmergencySosDialog.show(
                          context,
                          city: loc.city,
                          pincode: loc.pincode,
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626).withOpacity(0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Emergency SOS',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: const Text('15m', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Ambulance & Rites',
                                    style: TextStyle(color: Color(0xFFFECDD3), fontSize: 10.5, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Interactive Promo Banners Carousel
              SizedBox(
                height: 140,
                child: PageView.builder(
                  itemCount: _promoBanners.length,
                  onPageChanged: (idx) => setState(() => _activePromoIndex = idx),
                  itemBuilder: (context, idx) {
                    final item = _promoBanners[idx];
                    return Container(
                      margin: const EdgeInsets.only(right: 2),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item['colors'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: (item['colors'][0] as Color).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    item['tag'] as String,
                                    style: TextStyle(
                                      color: item['accent'] as Color,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['subtitle'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11.5,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item['icon'] as IconData, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Carousel Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_promoBanners.length, (idx) {
                  final isActive = idx == _activePromoIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primaryBlue : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Categories Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '10 Life Stages Categories',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  InkWell(
                    onTap: () => widget.onNavigateTab(1),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Categories Horizontal List with Custom Gradients
              SizedBox(
                height: 98,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: servicesCatalog.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final cat = servicesCatalog.categories[idx];
                    final style = _getCategoryStyle(cat.name);

                    return GestureDetector(
                      onTap: () {
                        widget.onNavigateTab(1);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: style['bg'] as Color,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: (style['color'] as Color).withOpacity(0.2),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (style['color'] as Color).withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(style['icon'] as IconData, color: style['color'] as Color, size: 26),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 68,
                            child: Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                                height: 1.15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 22),

              // Trust & Safety Pill Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TrustItem(icon: Icons.pin_outlined, label: '4-Digit OTP'),
                    _DividerDot(),
                    _TrustItem(icon: Icons.verified_user_outlined, label: 'Police Verified'),
                    _DividerDot(),
                    _TrustItem(icon: Icons.bolt_rounded, label: 'Instant Refund'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Featured Services Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Doorstep Services Catalog',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${servicesCatalog.services.length} services available',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (servicesCatalog.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(36),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (servicesCatalog.services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 10),
                      Text(
                        'No services found for ${loc.city}.',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try changing your location or clearing the search query.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                )
              else
                // GridView with Generous childAspectRatio (0.55) to GUARANTEE price and text never clip
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.55, // Ample height for image + title + rating + price + book CTA
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: servicesCatalog.services.length,
                  itemBuilder: (context, idx) {
                    final item = servicesCatalog.services[idx];
                    return ServiceCard(
                      service: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailScreen(slug: item.slug),
                          ),
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.successGreen),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

class _DividerDot extends StatelessWidget {
  const _DividerDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFFCBD5E1),
        shape: BoxShape.circle,
      ),
    );
  }
}
