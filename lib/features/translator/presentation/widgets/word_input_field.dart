import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WordInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final bool isLoading;

  const WordInputField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                textInputAction: TextInputAction.search,
                autocorrect: false,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                decoration: InputDecoration(
                  hintText: 'Введите слово (напр. Apfel, Buch)...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  suffixIcon: hasText
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.textSecondaryLight,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.clear();
                            onClear();
                          },
                          tooltip: 'Очистить',
                        )
                      : null,
                ),
                onSubmitted: onSubmitted,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: (hasText && !isLoading)
                    ? () => onSubmitted(controller.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.translate_rounded, size: 20),
                          SizedBox(width: 6),
                          Text('Найти'),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
