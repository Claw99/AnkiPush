import 'package:equatable/equatable.dart';
import '../../domain/entities/translation_option.dart';

abstract class TranslatorEvent extends Equatable {
  const TranslatorEvent();

  @override
  List<Object?> get props => [];
}

/// User triggered search for a word
class TranslateWordSubmitted extends TranslatorEvent {
  final String word;

  const TranslateWordSubmitted(this.word);

  @override
  List<Object?> get props => [word];
}

/// User tapped on a translation option to select or deselect it
class TranslationOptionToggled extends TranslatorEvent {
  final TranslationOption option;

  const TranslationOptionToggled(this.option);

  @override
  List<Object?> get props => [option];
}

/// User cleared the input field
class ClearWordRequested extends TranslatorEvent {
  const ClearWordRequested();
}

/// Language pair changed (e.g. de -> ru or de -> en)
class LanguagePairChanged extends TranslatorEvent {
  final String sourceLang;
  final String targetLang;

  const LanguagePairChanged({
    required this.sourceLang,
    required this.targetLang,
  });

  @override
  List<Object?> get props => [sourceLang, targetLang];
}

/// User requested sending the card to AnkiDroid
class AddCardToAnkiRequested extends TranslatorEvent {
  const AddCardToAnkiRequested();
}
