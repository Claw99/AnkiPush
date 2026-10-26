import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/word_translation.dart';
import '../repositories/translation_repository.dart';

class GetTranslationsParams extends Equatable {
  final String word;
  final String sourceLang;
  final String targetLang;

  const GetTranslationsParams({
    required this.word,
    this.sourceLang = 'de',
    this.targetLang = 'ru',
  });

  @override
  List<Object?> get props => [word, sourceLang, targetLang];
}

class GetTranslationsUseCase {
  final TranslationRepository repository;

  const GetTranslationsUseCase(this.repository);

  Future<Result<WordTranslation>> call(GetTranslationsParams params) async {
    final trimmedWord = params.word.trim();
    if (trimmedWord.isEmpty) {
      return Result.failure(const UnexpectedFailure('Введите слово для перевода'));
    }

    return repository.getTranslations(
      word: trimmedWord,
      sourceLang: params.sourceLang,
      targetLang: params.targetLang,
    );
  }
}
