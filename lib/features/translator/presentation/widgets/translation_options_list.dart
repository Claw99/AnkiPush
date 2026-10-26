import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/translation_option.dart';

class TranslationOptionsList extends StatelessWidget {
  final List<TranslationOption> options;
  final Set<TranslationOption> selectedOptions;
  final ValueChanged<TranslationOption> onOptionToggled;

  const TranslationOptionsList({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onOptionToggled,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.outline.withAlpha(120),
              ),
              const SizedBox(height: 16),
              Text(
                'Варианты перевода не найдены',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = selectedOptions.contains(option);

        return _TranslationOptionCard(
          option: option,
          isSelected: isSelected,
          onTap: () => onOptionToggled(option),
        );
      },
    );
  }
}

class _TranslationOptionCard extends StatelessWidget {
  final TranslationOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _TranslationOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight);

    final backgroundColor = isSelected
        ? (isDark
            ? AppColors.primary.withAlpha(40)
            : AppColors.primaryContainer.withAlpha(120))
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final matchPercent = (option.quality * 100).round();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.cardBorderDark
                              : const Color(0xFFCBD5E1)),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 14),

                // Translation text & details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (option.sourceSegment != null &&
                          option.sourceSegment!.isNotEmpty &&
                          option.sourceSegment!.toLowerCase() != option.text.toLowerCase()) ...[
                        const SizedBox(height: 2),
                        Text(
                          option.sourceSegment!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Match quality badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getQualityBadgeColor(matchPercent).withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getQualityBadgeColor(matchPercent).withAlpha(100),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: _getQualityBadgeColor(matchPercent),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$matchPercent%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getQualityBadgeColor(matchPercent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getQualityBadgeColor(int percent) {
    if (percent >= 80) return AppColors.qualityHigh;
    if (percent >= 60) return AppColors.qualityMedium;
    return AppColors.qualityLow;
  }
}
