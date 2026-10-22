import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/app_theme.dart';

class EmergencySosDialog extends StatefulWidget {
  final String userCity;
  final String userPincode;
  final String? initialName;
  final String? initialMobile;

  const EmergencySosDialog({
    super.key,
    required this.userCity,
    required this.userPincode,
    this.initialName,
    this.initialMobile,
  });

  static void show(BuildContext context, {
    required String city,
    required String pincode,
    String? name,
    String? mobile,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => EmergencySosDialog(
        userCity: city,
        userPincode: pincode,
        initialName: name,
        initialMobile: mobile,
      ),
    );
  }

  @override
  State<EmergencySosDialog> createState() => _EmergencySosDialogState();
}

class _EmergencySosDialogState extends State<EmergencySosDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'ambulance'; // 'ambulance' or 'last_rites'
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _addressController;
  final ApiService _api = ApiService();
  bool _isDispatching = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _mobileController = TextEditingController(text: widget.initialMobile ?? '');
    _addressController = TextEditingController(text: 'Current GPS Location, ${widget.userCity}');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _dispatch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isDispatching = true);

    try {
      final res = await _api.post('/emergency/dispatch', {
        'type': _selectedType,
        'contact_name': _nameController.text.trim(),
        'contact_mobile': _mobileController.text.trim(),
        'current_address': _addressController.text.trim(),
        'city': widget.userCity,
        'pincode': widget.userPincode,
      });

      setState(() => _isDispatching = false);

      if (res.success && mounted) {
        Navigator.pop(context);
        final data = res.data as Map<String, dynamic>;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 28),
                SizedBox(width: 8),
                Text('EMERGENCY DISPATCHED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${data['bookingNumber']} has been issued to the rapid response fleet.',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Estimated Arrival: 15-20 Mins', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF991B1B))),
                      const SizedBox(height: 4),
                      Text('Doorstep Security OTP: ${data['serviceOtp']}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB91C1C), fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Direct Hotline: ${data['helpline']}', style: const TextStyle(fontSize: 12, color: Color(0xFF7F1D1D))),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK, Monitor Dispatch'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: AppTheme.dangerRed),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDispatching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.emergency_rounded, color: AppTheme.dangerRed, size: 26),
          SizedBox(width: 8),
          Text('24x7 Priority Emergency SOS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rapid response dispatch within 15 minutes across 28+ Indian States.',
                style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 14),

              // Selector: Ambulance vs Funeral
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('🚑 Ambulance', style: TextStyle(fontSize: 12))),
                      selected: _selectedType == 'ambulance',
                      selectedColor: const Color(0xFFFEE2E2),
                      onSelected: (val) => setState(() => _selectedType = 'ambulance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('🕊️ Last Rites', style: TextStyle(fontSize: 12))),
                      selected: _selectedType == 'last_rites',
                      selectedColor: const Color(0xFFF1F5F9),
                      onSelected: (val) => setState(() => _selectedType = 'last_rites'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Caller Name', isDense: true),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(labelText: 'Primary Contact Mobile (+91)', isDense: true, counterText: ''),
                validator: (val) => val == null || val.trim().length != 10 ? '10 digits required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Current Location / Landmark', isDense: true),
                validator: (val) => val == null || val.trim().isEmpty ? 'Location required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _isDispatching ? null : _dispatch,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
          child: _isDispatching
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('DISPATCH NOW (15 Mins)'),
        ),
      ],
    );
  }
}
