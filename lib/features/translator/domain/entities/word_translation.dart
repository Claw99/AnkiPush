import 'package:equatable/equatable.dart';
import 'translation_option.dart';

/// Represents a source word and its list of translation options
class WordTranslation extends Equatable {
  final String sourceWord;
  final String sourceLanguage;
  final String targetLanguage;
  final List<TranslationOption> options;

  const WordTranslation({
    required this.sourceWord,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.options,
  });

  /// Returns true if at least one translation option is available
  bool get hasOptions => options.isNotEmpty;

  /// Returns the primary/top translation text
  String get primaryTranslation =>
      options.isNotEmpty ? options.first.text : '';

  @override
  List<Object?> get props => [sourceWord, sourceLanguage, targetLanguage, options];
}
