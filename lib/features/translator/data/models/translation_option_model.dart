import '../../domain/entities/translation_option.dart';

class TranslationOptionModel extends TranslationOption {
  const TranslationOptionModel({
    required super.id,
    required super.text,
    super.sourceSegment,
    super.quality,
    super.usageCount,
  });

  factory TranslationOptionModel.fromJson(Map<String, dynamic> json) {
    final rawText = (json['translation'] ?? json['text'] ?? '').toString();
    final cleanText = cleanHtmlEntities(rawText);

    final rawQuality = json['quality'] ?? json['match'] ?? 1.0;
    double parsedQuality = 1.0;
    if (rawQuality is num) {
      parsedQuality = rawQuality > 1.0 ? rawQuality / 100.0 : rawQuality.toDouble();
    } else if (rawQuality is String) {
      final parsed = double.tryParse(rawQuality) ?? 1.0;
      parsedQuality = parsed > 1.0 ? parsed / 100.0 : parsed;
    }

    final rawUsage = json['usage-count'] ?? json['usageCount'] ?? 1;
    final int parsedUsage = rawUsage is int
        ? rawUsage
        : int.tryParse(rawUsage.toString()) ?? 1;

    return TranslationOptionModel(
      id: (json['id'] ?? cleanText.hashCode).toString(),
      text: cleanText,
      sourceSegment: json['segment']?.toString(),
      quality: parsedQuality.clamp(0.0, 1.0),
      usageCount: parsedUsage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'sourceSegment': sourceSegment,
      'quality': quality,
      'usageCount': usageCount,
    };
  }

  static String cleanHtmlEntities(String text) {
    return text
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}
