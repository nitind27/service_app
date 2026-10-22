import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/location_provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/service_card.dart';
import 'service_detail_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final Function(int) onNavigateTab;
  const CategoriesScreen({super.key, required this.onNavigateTab});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedCategorySlug = 'all';

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ServiceCatalogProvider>();
    final loc = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('All Service Categories', style: TextStyle(fontWeight: FontWeight.w800)),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Horizontal Filter Chips
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('All Services'),
                  selected: _selectedCategorySlug == 'all',
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: _selectedCategorySlug == 'all' ? FontWeight.w800 : FontWeight.w600,
                    color: _selectedCategorySlug == 'all' ? Colors.white : const Color(0xFF334155),
                  ),
                  selectedColor: AppTheme.primaryBlue,
                  backgroundColor: const Color(0xFFF1F5F9),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (val) {
                    setState(() => _selectedCategorySlug = 'all');
                    catalog.fetchServices(city: loc.city, categorySlug: '');
                  },
                ),
                const SizedBox(width: 8),
                ...catalog.categories.map((c) {
                  final isSelected = _selectedCategorySlug == c.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: isSelected,
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                      selectedColor: AppTheme.primaryBlue,
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (val) {
                        setState(() => _selectedCategorySlug = c.slug);
                        catalog.fetchServices(city: loc.city, categorySlug: c.slug);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Services Grid
          Expanded(
            child: catalog.isLoading
                ? const Center(child: CircularProgressIndicator())
                : catalog.services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_rounded, size: 56, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'No services found in this category for ${loc.city}.',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select another category or view all services.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.55, // Generous height for image + title + rating + price + book button
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: catalog.services.length,
                        itemBuilder: (context, idx) {
                          final item = catalog.services[idx];
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
          ),
        ],
      ),
    );
  }
}
