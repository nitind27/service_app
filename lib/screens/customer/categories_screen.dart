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
      appBar: AppBar(
        title: const Text('All Service Categories', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          // Horizontal Filter Chips
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('All Services'),
                  selected: _selectedCategorySlug == 'all',
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
          const Divider(height: 1),
          // Services Grid
          Expanded(
            child: catalog.isLoading
                ? const Center(child: CircularProgressIndicator())
                : catalog.services.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_rounded, size: 56, color: AppTheme.textLight),
                            const SizedBox(height: 12),
                            Text(
                              'No services found in this category for ${loc.city}.',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
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
