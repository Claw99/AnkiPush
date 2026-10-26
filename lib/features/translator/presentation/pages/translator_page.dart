import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/translator_bloc.dart';
import '../bloc/translator_event.dart';
import '../bloc/translator_state.dart';
import '../widgets/action_button.dart';
import '../widgets/translation_options_list.dart';
import '../widgets/word_input_field.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String word) {
    if (word.trim().isNotEmpty) {
      FocusScope.of(context).unfocus();
      context.read<TranslatorBloc>().add(TranslateWordSubmitted(word));
    }
  }

  void _onClear() {
    context.read<TranslatorBloc>().add(const ClearWordRequested());
  }

  void _onAddToAnki() {
    context.read<TranslatorBloc>().add(const AddCardToAnkiRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<TranslatorBloc, TranslatorState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.ankiStatus != current.ankiStatus,
      listener: (context, state) {
        // Translation error listener
        if (state.isFailure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Anki export success listener
        if (state.ankiStatus == AnkiExportStatus.success) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Открываем AnkiDroid...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Anki export failure listener
        if (state.ankiStatus == AnkiExportStatus.failure &&
            state.ankiErrorMessage != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      state.ankiErrorMessage!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AnkiPush'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.cardBorderDark
                            : AppColors.primary.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇩🇪 DE'),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: isDark ? Colors.white70 : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text('🇷🇺 RU'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: ActionButton(
            isEnabled: state.hasSelection,
            isLoading: state.isExportingToAnki,
            selectedCount: state.selectedOptions.length,
            onPressed: _onAddToAnki,
          ),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input field
                  WordInputField(
                    controller: _controller,
                    isLoading: state.isLoading,
                    onSubmitted: _onSearch,
                    onClear: _onClear,
                  ),
                  const SizedBox(height: 24),

                  // State view
                  _buildStateContent(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateContent(BuildContext context, TranslatorState state) {
    if (state.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Ищем варианты перевода для «${state.word}»...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.isFailure) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withAlpha(60)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              state.errorMessage ?? 'Не удалось получить перевод',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _onSearch(state.word),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Повторить попытку'),
            ),
          ],
        ),
      );
    }

    if (state.isSuccess && state.translation != null) {
      final translation = state.translation!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translation.sourceWord,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Выберите подходящие варианты для карточки:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: AppColors.secondary.withAlpha(25),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Text(
              //     '${translation.options.length} вариантов',
              //     style: const TextStyle(
              //       fontSize: 12,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.secondary,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          TranslationOptionsList(
            options: translation.options,
            selectedOptions: state.selectedOptions,
            onOptionToggled: (option) {
              context.read<TranslatorBloc>().add(
                TranslationOptionToggled(option),
              );
            },
          ),
        ],
      );
    }

    // Initial state: Suggestions & guidance
    return _buildInitialGuidance(context);
  }

  Widget _buildInitialGuidance(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final suggestions = ['Apfel', 'Buch', 'Laufen', 'Haus', 'Katze', 'Leben'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Поиск и создание карточек',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Введите слово на немецком языке',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Популярные примеры для проверки:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((word) {
              return ActionChip(
                label: Text(word),
                avatar: const Icon(Icons.search_rounded, size: 16),
                backgroundColor: isDark
                    ? AppColors.cardBorderDark.withAlpha(100)
                    : AppColors.backgroundLight,
                side: BorderSide(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : AppColors.cardBorderLight,
                ),
                onPressed: () {
                  _controller.text = word;
                  _onSearch(word);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
