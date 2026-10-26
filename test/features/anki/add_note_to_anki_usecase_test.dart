import 'package:flutter_test/flutter_test.dart';
import 'package:ankipush/core/error/failures.dart';
import 'package:ankipush/features/anki/domain/repositories/anki_repository.dart';
import 'package:ankipush/features/anki/domain/usecases/add_note_to_anki_usecase.dart';

class MockAnkiRepository implements AnkiRepository {
  Result<void>? mockResult;
  String? lastFront;
  String? lastBack;

  @override
  Future<Result<void>> addNote({
    required String front,
    required String back,
  }) async {
    lastFront = front;
    lastBack = back;
    return mockResult ?? Result.success(null);
  }
}

void main() {
  late MockAnkiRepository mockRepository;
  late AddNoteToAnkiUseCase useCase;

  setUp(() {
    mockRepository = MockAnkiRepository();
    useCase = AddNoteToAnkiUseCase(mockRepository);
  });

  test('successfully forwards note parameters to repository', () async {
    final result = await useCase(
      const AddNoteToAnkiParams(front: 'Apfel', back: 'яблоко'),
    );

    expect(result.isSuccess, isTrue);
    expect(mockRepository.lastFront, 'Apfel');
    expect(mockRepository.lastBack, 'яблоко');
  });

  test('returns failure when front or back is empty', () async {
    final result = await useCase(
      const AddNoteToAnkiParams(front: '   ', back: 'яблоко'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failure, isA<UnexpectedFailure>());
  });

  test('forwards repository failure', () async {
    mockRepository.mockResult = Result.failure(
      const AnkiNotInstalledFailure('Приложение AnkiDroid не найдено на устройстве'),
    );

    final result = await useCase(
      const AddNoteToAnkiParams(front: 'Apfel', back: 'яблоко'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failure, isA<AnkiNotInstalledFailure>());
  });
}
