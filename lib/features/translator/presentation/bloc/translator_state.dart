import 'package:equatable/equatable.dart';
import '../../domain/entities/translation_option.dart';
import '../../domain/entities/word_translation.dart';

enum TranslatorStatus { initial, loading, success, failure }

enum AnkiExportStatus { initial, loading, success, failure }

class TranslatorState extends Equatable {
  final TranslatorStatus status;
  final String word;
  final WordTranslation? translation;
  final Set<TranslationOption> selectedOptions;
  final String? errorMessage;
  final String sourceLang;
  final String targetLang;
  final AnkiExportStatus ankiStatus;
  final String? ankiErrorMessage;

  const TranslatorState({
    this.status = TranslatorStatus.initial,
    this.word = '',
    this.translation,
    this.selectedOptions = const <TranslationOption>{},
    this.errorMessage,
    this.sourceLang = 'de',
    this.targetLang = 'ru',
    this.ankiStatus = AnkiExportStatus.initial,
    this.ankiErrorMessage,
  });

  bool get isLoading => status == TranslatorStatus.loading;
  bool get isSuccess => status == TranslatorStatus.success;
  bool get isFailure => status == TranslatorStatus.failure;
  bool get hasSelection => selectedOptions.isNotEmpty;
  bool get isExportingToAnki => ankiStatus == AnkiExportStatus.loading;

  /// Returns comma-separated list of selected translations
  String get selectedTextsFormatted =>
      selectedOptions.map((e) => e.text).join(', ');

  TranslatorState copyWith({
    TranslatorStatus? status,
    String? word,
    WordTranslation? translation,
    Set<TranslationOption>? selectedOptions,
    String? errorMessage,
    bool clearError = false,
    String? sourceLang,
    String? targetLang,
    AnkiExportStatus? ankiStatus,
    String? ankiErrorMessage,
    bool clearAnkiError = false,
  }) {
    return TranslatorState(
      status: status ?? this.status,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      selectedOptions: selectedOptions ?? this.selectedOptions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      sourceLang: sourceLang ?? this.sourceLang,
      targetLang: targetLang ?? this.targetLang,
      ankiStatus: ankiStatus ?? this.ankiStatus,
      ankiErrorMessage: clearAnkiError
          ? null
          : (ankiErrorMessage ?? this.ankiErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        word,
        translation,
        selectedOptions,
        errorMessage,
        sourceLang,
        targetLang,
        ankiStatus,
        ankiErrorMessage,
      ];
}
