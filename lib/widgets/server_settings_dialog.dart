import 'package:flutter/material.dart';
import '../config/api_constants.dart';
import '../config/app_theme.dart';

class ServerSettingsDialog extends StatefulWidget {
  const ServerSettingsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ServerSettingsDialog(),
    );
  }

  @override
  State<ServerSettingsDialog> createState() => _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends State<ServerSettingsDialog> {
  late TextEditingController _urlController;
  String _selectedOption = '';

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConstants.baseUrl);
    _selectedOption = ApiConstants.baseUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _save(String url) async {
    await ApiConstants.setCustomBaseUrl(url);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backend URL set to: ${ApiConstants.baseUrl}'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns_rounded, color: AppTheme.primaryBlue),
          SizedBox(width: 8),
          Text('Backend Server API', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select or enter the Next.js API server host:',
              style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: ApiConstants.androidEmulatorUrl,
              groupValue: _selectedOption,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Android Emulator', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('http://10.0.2.2:3000/api', style: TextStyle(fontSize: 11)),
              onChanged: (val) {
                setState(() {
                  _selectedOption = val!;
                  _urlController.text = val;
                });
              },
            ),
            RadioListTile<String>(
              value: ApiConstants.lanWifiUrl,
              groupValue: _selectedOption,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Physical Phone over Wi-Fi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('http://192.168.1.14:3000/api', style: TextStyle(fontSize: 11)),
              onChanged: (val) {
                setState(() {
                  _selectedOption = val!;
                  _urlController.text = val;
                });
              },
            ),
            RadioListTile<String>(
              value: ApiConstants.localhostUrl,
              groupValue: _selectedOption,
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Windows Desktop / Web', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: const Text('http://localhost:3000/api', style: TextStyle(fontSize: 11)),
              onChanged: (val) {
                setState(() {
                  _selectedOption = val!;
                  _urlController.text = val;
                });
              },
            ),
            const SizedBox(height: 8),
            const Text('Custom Host / Port:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'http://192.168.1.XX:3000/api',
                isDense: true,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _save(_urlController.text),
          child: const Text('Save & Connect'),
        ),
      ],
    );
  }
}
