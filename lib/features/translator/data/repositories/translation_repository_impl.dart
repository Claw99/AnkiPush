import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/word_translation.dart';
import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_remote_data_source.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource remoteDataSource;

  const TranslationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<WordTranslation>> getTranslations({
    required String word,
    String sourceLang = 'de',
    String targetLang = 'ru',
  }) async {
    try {
      final result = await remoteDataSource.getTranslations(
        word: word,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
      return Result.success(result);
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.failure(UnexpectedFailure('Ошибка получения перевода: $e'));
    }
  }
}
