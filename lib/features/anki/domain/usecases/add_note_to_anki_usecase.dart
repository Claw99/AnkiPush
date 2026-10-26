import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/anki_repository.dart';

class AddNoteToAnkiParams extends Equatable {
  final String front;
  final String back;

  const AddNoteToAnkiParams({
    required this.front,
    required this.back,
  });

  @override
  List<Object?> get props => [front, back];
}

class AddNoteToAnkiUseCase {
  final AnkiRepository repository;

  const AddNoteToAnkiUseCase(this.repository);

  Future<Result<void>> call(AddNoteToAnkiParams params) async {
    final front = params.front.trim();
    final back = params.back.trim();

    if (front.isEmpty || back.isEmpty) {
      return Result.failure(
        const UnexpectedFailure('Слово и перевод не должны быть пустыми'),
      );
    }

    return repository.addNote(front: front, back: back);
  }
}
