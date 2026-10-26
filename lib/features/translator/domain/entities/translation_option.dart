import 'package:equatable/equatable.dart';

/// Represents a single translation alternative/sense for a word
class TranslationOption extends Equatable {
  final String id;
  final String text;
  final String? sourceSegment;
  final double quality; // 0.0 - 1.0 or percentage score
  final int usageCount;

  const TranslationOption({
    required this.id,
    required this.text,
    this.sourceSegment,
    this.quality = 1.0,
    this.usageCount = 1,
  });

  @override
  List<Object?> get props => [id, text, sourceSegment, quality, usageCount];
}
