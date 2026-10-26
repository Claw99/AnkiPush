import 'package:flutter_test/flutter_test.dart';
import 'package:ankipush/core/error/failures.dart';
import 'package:ankipush/features/anki/domain/repositories/anki_repository.dart';
import 'package:ankipush/features/anki/domain/usecases/add_note_to_anki_usecase.dart';
import 'package:ankipush/features/translator/domain/entities/translation_option.dart';
import 'package:ankipush/features/translator/domain/entities/word_translation.dart';
import 'package:ankipush/features/translator/domain/repositories/translation_repository.dart';
import 'package:ankipush/features/translator/domain/usecases/get_translations_usecase.dart';
import 'package:ankipush/features/translator/presentation/bloc/translator_bloc.dart';
import 'package:ankipush/features/translator/presentation/bloc/translator_event.dart';
import 'package:ankipush/features/translator/presentation/bloc/translator_state.dart';

class MockTranslationRepository implements TranslationRepository {
  Result<WordTranslation>? mockResult;

  @override
  Future<Result<WordTranslation>> getTranslations({
    required String word,
    String sourceLang = 'de',
    String targetLang = 'ru',
  }) async {
    return mockResult ??
        Result.success(
          WordTranslation(
            sourceWord: word,
            sourceLanguage: sourceLang,
            targetLanguage: targetLang,
            options: const [
              TranslationOption(id: '1', text: 'яблоко', quality: 1.0),
              TranslationOption(id: '2', text: 'яблочный', quality: 0.9),
            ],
          ),
        );
  }
}

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
  late MockTranslationRepository mockTranslationRepo;
  late MockAnkiRepository mockAnkiRepo;
  late GetTranslationsUseCase getTranslationsUseCase;
  late AddNoteToAnkiUseCase addNoteToAnkiUseCase;
  late TranslatorBloc bloc;

  setUp(() {
    mockTranslationRepo = MockTranslationRepository();
    mockAnkiRepo = MockAnkiRepository();
    getTranslationsUseCase = GetTranslationsUseCase(mockTranslationRepo);
    addNoteToAnkiUseCase = AddNoteToAnkiUseCase(mockAnkiRepo);
    bloc = TranslatorBloc(
      getTranslationsUseCase: getTranslationsUseCase,
      addNoteToAnkiUseCase: addNoteToAnkiUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is correct', () {
    expect(bloc.state.status, TranslatorStatus.initial);
    expect(bloc.state.ankiStatus, AnkiExportStatus.initial);
    expect(bloc.state.hasSelection, isFalse);
    expect(bloc.state.word, '');
  });

  test('emits loading and success when word translation succeeds', () async {
    final expectedStates = [
      predicate<TranslatorState>((s) => s.isLoading && s.word == 'Apfel'),
      predicate<TranslatorState>(
        (s) =>
            s.isSuccess &&
            s.translation != null &&
            s.hasSelection &&
            s.selectedOptions.first.text == 'яблоко',
      ),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const TranslateWordSubmitted('Apfel'));
  });

  test('toggles translation option selection correctly', () async {
    const option1 = TranslationOption(id: '1', text: 'яблоко');
    const option2 = TranslationOption(id: '2', text: 'яблочный');

    bloc.add(const TranslateWordSubmitted('Apfel'));
    await bloc.stream.firstWhere((s) => s.isSuccess);

    expect(bloc.state.selectedOptions.contains(option1), isTrue);

    // Toggle option 2 (add)
    bloc.add(const TranslationOptionToggled(option2));
    await bloc.stream.firstWhere((s) => s.selectedOptions.length == 2);
    expect(bloc.state.selectedOptions.contains(option2), isTrue);
    expect(bloc.state.selectedTextsFormatted, 'яблоко, яблочный');

    // Toggle option 1 (remove)
    bloc.add(const TranslationOptionToggled(option1));
    await bloc.stream.firstWhere((s) => s.selectedOptions.length == 1);
    expect(bloc.state.selectedOptions.contains(option1), isFalse);
    expect(bloc.state.selectedTextsFormatted, 'яблочный');
  });

  test('clears state on ClearWordRequested', () async {
    bloc.add(const TranslateWordSubmitted('Apfel'));
    await bloc.stream.firstWhere((s) => s.isSuccess);

    bloc.add(const ClearWordRequested());
    await bloc.stream.firstWhere((s) => s.status == TranslatorStatus.initial);

    expect(bloc.state.word, '');
    expect(bloc.state.translation, isNull);
    expect(bloc.state.selectedOptions, isEmpty);
  });

  test('handles AddCardToAnkiRequested successfully', () async {
    bloc.add(const TranslateWordSubmitted('Apfel'));
    await bloc.stream.firstWhere((s) => s.isSuccess);

    bloc.add(const AddCardToAnkiRequested());
    await bloc.stream.firstWhere((s) => s.ankiStatus == AnkiExportStatus.success);

    expect(mockAnkiRepo.lastFront, 'Apfel');
    expect(mockAnkiRepo.lastBack, 'яблоко');
  });

  test('handles AddCardToAnkiRequested failure when AnkiDroid not installed', () async {
    mockAnkiRepo.mockResult = Result.failure(
      const AnkiNotInstalledFailure('Приложение AnkiDroid не найдено на устройстве'),
    );

    bloc.add(const TranslateWordSubmitted('Apfel'));
    await bloc.stream.firstWhere((s) => s.isSuccess);

    bloc.add(const AddCardToAnkiRequested());
    await bloc.stream.firstWhere((s) => s.ankiStatus == AnkiExportStatus.failure);

    expect(bloc.state.ankiErrorMessage, 'Приложение AnkiDroid не найдено на устройстве');
  });
}
