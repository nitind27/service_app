import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../config/app_theme.dart';

class LocationBottomSheet extends StatefulWidget {
  const LocationBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationBottomSheet(),
    );
  }

  @override
  State<LocationBottomSheet> createState() => _LocationBottomSheetState();
}

class _LocationBottomSheetState extends State<LocationBottomSheet> {
  String? _selectedStateName;

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();
    _selectedStateName ??= locProvider.state;

    final selectedStateObj = LocationProvider.indianStates.firstWhere(
      (s) => s.state.toLowerCase() == _selectedStateName?.toLowerCase(),
      orElse: () => LocationProvider.indianStates.first,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Doorstep services available across 28+ States',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 16),
                // Auto Detect GPS Button
                InkWell(
                  onTap: locProvider.isDetecting
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final success = await locProvider.autoDetectLocation();
                          if (success) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Location updated to ${locProvider.displayText}'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                            navigator.pop();
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        locProvider.isDetecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                              )
                            : const Icon(Icons.my_location_rounded, color: AppTheme.primaryBlue, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Detect My Location',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'Using GPS or Network IP',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppTheme.primaryBlue, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Split selector: States on left, Cities on right
          Expanded(
            child: Row(
              children: [
                // States Column
                Container(
                  width: 140,
                  color: Colors.grey.shade50,
                  child: ListView.builder(
                    itemCount: LocationProvider.indianStates.length,
                    itemBuilder: (context, idx) {
                      final item = LocationProvider.indianStates[idx];
                      final isSelected = item.state.toLowerCase() == selectedStateObj.state.toLowerCase();
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedStateName = item.state;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            border: Border(
                              left: BorderSide(
                                color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            item.state,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.textMedium,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Cities Column
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: selectedStateObj.cities.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final city = selectedStateObj.cities[idx];
                      final isCurrent = city.toLowerCase() == locProvider.city.toLowerCase() &&
                          selectedStateObj.state.toLowerCase() == locProvider.state.toLowerCase();
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        title: Text(
                          city,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent ? AppTheme.primaryBlue : AppTheme.textDark,
                          ),
                        ),
                        trailing: isCurrent
                            ? const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20)
                            : null,
                        onTap: () {
                          locProvider.setLocation(city, selectedStateObj.state);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
