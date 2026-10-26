import '../../../../core/error/failures.dart';
import '../entities/word_translation.dart';

abstract class TranslationRepository {
  Future<Result<WordTranslation>> getTranslations({
    required String word,
    String sourceLang = 'de',
    String targetLang = 'ru',
  });
}
