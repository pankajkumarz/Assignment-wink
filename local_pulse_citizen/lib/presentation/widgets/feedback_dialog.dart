import 'package:flutter/material.dart';

import '../../domain/entities/issue.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({
    super.key,
    required this.issue,
    required this.onSubmit,
  });

  final Issue issue;
  final Function(int rating, String? comment) onSubmit;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Rate Resolution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Issue Title
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Issue Resolved',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.issue.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Rating Section
            Text(
              'How satisfied are you with the resolution?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 16),

            // Star Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating
                          ? Colors.amber
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Rating Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Poor',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Excellent',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Comment Section
            Text(
              'Additional Comments (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _commentController,
              label: 'Your feedback',
              hint: 'Tell us about your experience...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () => Navigator.of(context).pop(),
                    text: 'Cancel',
                    variant: ButtonVariant.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    onPressed: _rating > 0 ? _submitFeedback : null,
                    text: 'Submit',
                    icon: Icons.send,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback() {
    widget.onSubmit(
      _rating,
      _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );
    Navigator.of(context).pop();
  }
}

// Helper function to show feedback dialog
Future<void> showFeedbackDialog(
  BuildContext context,
  Issue issue,
  Function(int rating, String? comment) onSubmit,
) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => FeedbackDialog(
      issue: issue,
      onSubmit: onSubmit,
    ),
  );
}