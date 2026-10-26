import '../../domain/entities/word_translation.dart';
import 'translation_option_model.dart';

class WordTranslationModel extends WordTranslation {
  const WordTranslationModel({
    required super.sourceWord,
    required super.sourceLanguage,
    required super.targetLanguage,
    required super.options,
  });

  factory WordTranslationModel.fromApiResponse({
    required Map<String, dynamic> json,
    required String sourceWord,
    required String sourceLang,
    required String targetLang,
  }) {
    final List<TranslationOptionModel> parsedOptions = [];
    final Set<String> seenTexts = <String>{};

    // 1. Primary translation from responseData
    final responseData = json['responseData'] as Map<String, dynamic>?;
    if (responseData != null) {
      final rawPrimary = responseData['translatedText']?.toString() ?? '';
      final cleanPrimary = TranslationOptionModel.cleanHtmlEntities(rawPrimary);
      if (cleanPrimary.isNotEmpty && !cleanPrimary.toLowerCase().contains('mymemory')) {
        parsedOptions.add(
          TranslationOptionModel(
            id: 'primary_${cleanPrimary.hashCode}',
            text: cleanPrimary,
            quality: 1.0,
            usageCount: 10,
          ),
        );
        seenTexts.add(cleanPrimary.toLowerCase());
      }
    }

    // 2. Additional matches from matches array
    final matches = json['matches'] as List<dynamic>?;
    if (matches != null) {
      for (final matchItem in matches) {
        if (matchItem is Map<String, dynamic>) {
          final option = TranslationOptionModel.fromJson(matchItem);
          final lower = option.text.toLowerCase();
          // Filter out empty, watermarks, or duplicates
          if (option.text.isNotEmpty &&
              !lower.contains('mymemory') &&
              !seenTexts.contains(lower)) {
            parsedOptions.add(option);
            seenTexts.add(lower);
          }
        }
      }
    }

    return WordTranslationModel(
      sourceWord: sourceWord,
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
      options: parsedOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceWord': sourceWord,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'options': options
          .map((e) => (e is TranslationOptionModel) ? e.toJson() : {
                'id': e.id,
                'text': e.text,
                'sourceSegment': e.sourceSegment,
                'quality': e.quality,
                'usageCount': e.usageCount,
              })
          .toList(),
    };
  }
}
