import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/service_model.dart';
import '../../config/app_theme.dart';
import '../../config/price_formatter.dart';
import 'service_detail_screen.dart';

class SmartAssistantScreen extends StatefulWidget {
  const SmartAssistantScreen({super.key});

  @override
  State<SmartAssistantScreen> createState() => _SmartAssistantScreenState();
}

class _SmartAssistantScreenState extends State<SmartAssistantScreen> {
  final TextEditingController _issueController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _diagnosisResult;

  final List<String> _quickScenarios = [
    'AC water leaking and low cooling',
    'Full home deep cleaning before moving in',
    'Elderly patient needs daily nurse at home',
    'Learned Pandit Ji for Griha Pravesh pooja',
    'Urgent emergency ambulance with oxygen',
    'CA consultation for GST & tax filing',
    'Dignified last rites & hearse assistance',
  ];

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _diagnose(String text) async {
    final queryText = text.trim();
    if (queryText.isEmpty) return;

    _issueController.text = queryText;
    setState(() {
      _isAnalyzing = true;
      _diagnosisResult = null;
    });

    try {
      final res = await _api.post('/assistant/diagnose', {
        'issue_text': queryText,
      });

      setState(() => _isAnalyzing = false);

      if (res.success && res.data != null && mounted) {
        setState(() {
          _diagnosisResult = res.data as Map<String, dynamic>;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: AppTheme.dangerRed),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.dangerRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ServiceModel? service;
    if (_diagnosisResult != null && _diagnosisResult!['service'] != null) {
      service = ServiceModel.fromJson(_diagnosisResult!['service'] as Map<String, dynamic>);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryBlue, size: 22),
            SizedBox(width: 8),
            Text('Jeevan Mitra AI Guide', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology_rounded, color: Color(0xFFFDBA74), size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Problem Diagnostic',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Not sure which service or package to select? Describe your issue and our AI engine will match the exact solution.',
                          style: TextStyle(color: Color(0xFFDBEAFE), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _issueController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'e.g. My AC is making rattling noise and blowing room temperature air...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AI Instant Diagnosis', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ElevatedButton.icon(
                        onPressed: _isAnalyzing ? null : () => _diagnose(_issueController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: _isAnalyzing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.bolt_rounded, size: 18),
                        label: Text(_isAnalyzing ? 'Analyzing...' : 'Diagnose Now', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick scenario chips
            const Text(
              'Or tap common household scenarios:',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickScenarios.map((item) {
                return ActionChip(
                  label: Text(item, style: const TextStyle(fontSize: 11.5)),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  onPressed: () => _diagnose(item),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Diagnosis Result Section
            if (_diagnosisResult != null) ...[
              const Text(
                'Diagnostic Analysis & Recommendation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.06), blurRadius: 10),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF86EFAC)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${_diagnosisResult!['confidenceScore']} Match',
                                style: const TextStyle(color: Color(0xFF166534), fontSize: 11, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _diagnosisResult!['urgency']?.toString() ?? '',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.accentOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      'Technical Diagnosis:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _diagnosisResult!['diagnosis']?.toString() ?? '',
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B), height: 1.35),
                    ),
                    const Divider(height: 22),

                    if (service != null) ...[
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              service.thumbnail ?? '',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey.shade200),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  PriceFormatter.format(service.effectivePrice),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailScreen(slug: service!.slug),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Book Recommended Service', style: TextStyle(fontWeight: FontWeight.w800)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
