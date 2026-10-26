import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/anki_repository.dart';
import '../datasources/anki_data_source.dart';

class AnkiRepositoryImpl implements AnkiRepository {
  final AnkiDataSource dataSource;

  const AnkiRepositoryImpl({required this.dataSource});

  @override
  Future<Result<void>> addNote({
    required String front,
    required String back,
  }) async {
    try {
      await dataSource.sendNoteIntent(front: front, back: back);
      return Result.success(null);
    } on AnkiNotInstalledException catch (e) {
      return Result.failure(AnkiNotInstalledFailure(e.message));
    } on AnkiException catch (e) {
      return Result.failure(AnkiFailure(e.message));
    } catch (e) {
      return Result.failure(
        AnkiNotInstalledFailure('Не удалось открыть AnkiDroid: $e'),
      );
    }
  }
}
