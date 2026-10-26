import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../anki/domain/usecases/add_note_to_anki_usecase.dart';
import '../../domain/entities/translation_option.dart';
import '../../domain/usecases/get_translations_usecase.dart';
import 'translator_event.dart';
import 'translator_state.dart';

class TranslatorBloc extends Bloc<TranslatorEvent, TranslatorState> {
  final GetTranslationsUseCase getTranslationsUseCase;
  final AddNoteToAnkiUseCase addNoteToAnkiUseCase;

  TranslatorBloc({
    required this.getTranslationsUseCase,
    required this.addNoteToAnkiUseCase,
  }) : super(const TranslatorState()) {
    on<TranslateWordSubmitted>(_onTranslateWordSubmitted);
    on<TranslationOptionToggled>(_onTranslationOptionToggled);
    on<ClearWordRequested>(_onClearWordRequested);
    on<LanguagePairChanged>(_onLanguagePairChanged);
    on<AddCardToAnkiRequested>(_onAddCardToAnkiRequested);
  }

  Future<void> _onTranslateWordSubmitted(
    TranslateWordSubmitted event,
    Emitter<TranslatorState> emit,
  ) async {
    final query = event.word.trim();
    if (query.isEmpty) {
      emit(
        state.copyWith(
          status: TranslatorStatus.failure,
          errorMessage: 'Введите слово для перевода',
          ankiStatus: AnkiExportStatus.initial,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TranslatorStatus.loading,
        word: query,
        selectedOptions: const <TranslationOption>{},
        clearError: true,
        ankiStatus: AnkiExportStatus.initial,
      ),
    );

    final result = await getTranslationsUseCase(
      GetTranslationsParams(
        word: query,
        sourceLang: state.sourceLang,
        targetLang: state.targetLang,
      ),
    );

    result.fold(
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: TranslatorStatus.failure,
            errorMessage: failure.message,
            ankiStatus: AnkiExportStatus.initial,
          ),
        );
      },
      onSuccess: (wordTranslation) {
        // Pre-select the first (highest quality) translation by default for convenience
        final initialSelected = wordTranslation.options.isNotEmpty
            ? {wordTranslation.options.first}
            : <TranslationOption>{};

        emit(
          state.copyWith(
            status: TranslatorStatus.success,
            translation: wordTranslation,
            selectedOptions: initialSelected,
            clearError: true,
            ankiStatus: AnkiExportStatus.initial,
          ),
        );
      },
    );
  }

  void _onTranslationOptionToggled(
    TranslationOptionToggled event,
    Emitter<TranslatorState> emit,
  ) {
    final updated = Set<TranslationOption>.from(state.selectedOptions);
    if (updated.contains(event.option)) {
      updated.remove(event.option);
    } else {
      updated.add(event.option);
    }

    emit(
      state.copyWith(
        selectedOptions: updated,
        ankiStatus: AnkiExportStatus.initial,
      ),
    );
  }

  void _onClearWordRequested(
    ClearWordRequested event,
    Emitter<TranslatorState> emit,
  ) {
    emit(
      const TranslatorState(),
    );
  }

  Future<void> _onLanguagePairChanged(
    LanguagePairChanged event,
    Emitter<TranslatorState> emit,
  ) async {
    emit(
      state.copyWith(
        sourceLang: event.sourceLang,
        targetLang: event.targetLang,
        ankiStatus: AnkiExportStatus.initial,
      ),
    );

    if (state.word.trim().isNotEmpty) {
      add(TranslateWordSubmitted(state.word));
    }
  }

  Future<void> _onAddCardToAnkiRequested(
    AddCardToAnkiRequested event,
    Emitter<TranslatorState> emit,
  ) async {
    final front = state.translation?.sourceWord ?? state.word;
    final back = state.selectedTextsFormatted;

    if (front.trim().isEmpty || back.trim().isEmpty) {
      emit(
        state.copyWith(
          ankiStatus: AnkiExportStatus.failure,
          ankiErrorMessage: 'Выберите хотя бы один перевод перед добавлением в Anki',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        ankiStatus: AnkiExportStatus.loading,
        clearAnkiError: true,
      ),
    );

    final result = await addNoteToAnkiUseCase(
      AddNoteToAnkiParams(
        front: front,
        back: back,
      ),
    );

    result.fold(
      onFailure: (failure) {
        emit(
          state.copyWith(
            ankiStatus: AnkiExportStatus.failure,
            ankiErrorMessage: failure.message,
          ),
        );
      },
      onSuccess: (_) {
        emit(
          state.copyWith(
            ankiStatus: AnkiExportStatus.success,
            clearAnkiError: true,
          ),
        );
      },
    );
  }
}
