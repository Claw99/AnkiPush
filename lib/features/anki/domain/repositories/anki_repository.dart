import '../../../../core/error/failures.dart';

abstract class AnkiRepository {
  Future<Result<void>> addNote({
    required String front,
    required String back,
  });
}
