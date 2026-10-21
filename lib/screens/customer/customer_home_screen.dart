import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/service_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/location_bottom_sheet.dart';
import '../../widgets/service_card.dart';
import 'service_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  const CustomerHomeScreen({super.key, required this.onNavigateTab});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final servicesCatalog = context.watch<ServiceCatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.handshake_rounded, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 6),
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
                    color: AppTheme.accentOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ALL SERVICES',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentOrangeDark,
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
                  const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.accentOrange),
                  const SizedBox(width: 4),
                  Text(
                    loc.displayText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppTheme.textMedium),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // 24x7 Helpline Icon
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.headset_mic_rounded, color: AppTheme.primaryBlue),
              tooltip: '24x7 Helpline Support',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.support_agent_rounded, color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text('24x7 Support Helpline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toll-Free Customer Care:', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                        SizedBox(height: 4),
                        Text('1800-123-5338 (JEEVAN)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                        SizedBox(height: 12),
                        Text('Emergency Ambulance & Last Rites:', style: TextStyle(fontSize: 13, color: AppTheme.textMedium)),
                        SizedBox(height: 4),
                        Text('+91 98765 43210 (Direct Dispatch)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.dangerRed)),
                      ],
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ],
                  ),
                );
              },
            ),
          ),
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
              // Search Bar
              TextField(
                controller: _searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'Search cleaning, doctor, pandit, repair...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textLight),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearch('');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Emergency & Priority Services Alert Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF2F2), Color(0xFFFFF1F2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.emergency_rounded, color: AppTheme.dangerRed, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                '24x7 Priority & Emergency',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.bolt, size: 14, color: AppTheme.dangerRed),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Ambulance, ICU at Home & Last Rites funeral support across India',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7F1D1D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF991B1B)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Categories Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Life Stages & Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateTab(1),
                    child: const Text('View All', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Categories Horizontal Scroll / Grid
              SizedBox(
                height: 105,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: servicesCatalog.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final cat = servicesCatalog.categories[idx];
                    return GestureDetector(
                      onTap: () {
                        widget.onNavigateTab(1);
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFDBEAFE)),
                            ),
                            child: const Center(
                              child: Icon(Icons.category_rounded, color: AppTheme.primaryBlue, size: 26),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 72,
                            child: Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
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
              const SizedBox(height: 20),
              // Doorstep Security Trust Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.shield_rounded, color: Color(0xFFFDBA74), size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Doorstep 4-Digit OTP Protection',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Technicians start jobs only after you verify the OTP at your door. 100% Instant Wallet Refund on cancellation.',
                            style: TextStyle(
                              color: Color(0xFFBFDBFE),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Featured Services Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Featured Doorstep Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    '${servicesCatalog.services.length} available',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMedium),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (servicesCatalog.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (servicesCatalog.services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textLight),
                      SizedBox(height: 8),
                      Text('No services found matching your search.', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
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
            ],
          ),
        ),
      ),
    );
  }
}
