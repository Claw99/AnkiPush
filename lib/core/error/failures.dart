import 'package:equatable/equatable.dart';

/// Base class for domain-level failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Проверьте подключение к интернету']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Переводы для данного слова не найдены']);
}

class AnkiNotInstalledFailure extends Failure {
  const AnkiNotInstalledFailure([super.message = 'Приложение AnkiDroid не найдено на устройстве']);
}

class AnkiFailure extends Failure {
  const AnkiFailure([super.message = 'Не удалось передать карточку в AnkiDroid']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Произошла непредвиденная ошибка']);
}

/// Generic Result type to represent either a Success with [T] or a [Failure]
class Result<T> extends Equatable {
  final T? _data;
  final Failure? _failure;

  const Result.success(T data)
      : _data = data,
        _failure = null;

  const Result.failure(Failure failure)
      : _data = null,
        _failure = failure;

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get data {
    if (_data == null) {
      throw StateError('Cannot access data on a failed Result');
    }
    return _data;
  }

  Failure get failure {
    if (_failure == null) {
      throw StateError('Cannot access failure on a successful Result');
    }
    return _failure;
  }

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    if (isSuccess) {
      return onSuccess(_data as T);
    } else {
      return onFailure(_failure!);
    }
  }

  @override
  List<Object?> get props => [_data, _failure];
}
