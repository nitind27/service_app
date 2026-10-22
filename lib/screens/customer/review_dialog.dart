import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/app_theme.dart';

class ReviewDialog extends StatefulWidget {
  final int bookingId;
  final String serviceTitle;
  final VoidCallback onSubmitted;

  const ReviewDialog({
    super.key,
    required this.bookingId,
    required this.serviceTitle,
    required this.onSubmitted,
  });

  static void show(BuildContext context, {
    required int bookingId,
    required String serviceTitle,
    required VoidCallback onSubmitted,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => ReviewDialog(
        bookingId: bookingId,
        serviceTitle: serviceTitle,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  int _selectedStars = 5;
  final TextEditingController _reviewController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isSubmitting = false;

  final List<String> _tags = [
    'Punctual Arrival',
    'Polite & Courteous',
    'Expert Technique',
    'Clean Workspace',
    'Fair Pricing',
  ];
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    String finalReview = _reviewController.text.trim();
    if (_selectedTags.isNotEmpty) {
      final tagStr = _selectedTags.join(', ');
      finalReview = finalReview.isEmpty ? tagStr : '$finalReview ($tagStr)';
    }

    try {
      final res = await _api.post('/reviews', {
        'booking_id': widget.bookingId,
        'rating': _selectedStars,
        'review_text': finalReview,
      });

      setState(() => _isSubmitting = false);

      if (res.success && mounted) {
        Navigator.pop(context);
        widget.onSubmitted();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you! Your feedback helps keep service quality top-rated.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res.message), backgroundColor: AppTheme.dangerRed),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
          Icon(Icons.star_rounded, color: AppTheme.warningAmber, size: 26),
          SizedBox(width: 8),
          Text('Rate Your Experience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.serviceTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 14),

            // 5 Stars Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNum = index + 1;
                final isFilled = starNum <= _selectedStars;
                return IconButton(
                  icon: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? AppTheme.warningAmber : const Color(0xFFCBD5E1),
                    size: 34,
                  ),
                  onPressed: () => setState(() => _selectedStars = starNum),
                );
              }),
            ),
            Text(
              _selectedStars == 5
                  ? 'Excellent & Professional! ⭐⭐⭐⭐⭐'
                  : (_selectedStars >= 4 ? 'Very Good Service' : 'Satisfactory'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),

            // Quick compliment tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((tag) {
                final isChosen = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag, style: TextStyle(fontSize: 11, fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500)),
                  selected: isChosen,
                  selectedColor: const Color(0xFFEFF6FF),
                  checkmarkColor: AppTheme.primaryBlue,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Share any details about the technician and service...',
                isDense: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
          child: _isSubmitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Submit Review'),
        ),
      ],
    );
  }
}
