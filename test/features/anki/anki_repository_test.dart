import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ankipush/core/error/failures.dart';
import 'package:ankipush/features/anki/data/datasources/anki_data_source.dart';
import 'package:ankipush/features/anki/data/repositories/anki_repository_impl.dart';

void main() {
  test('AnkiRepositoryImpl returns success when dataSource succeeds', () async {
    final dataSource = AnkiDataSourceImpl(
      launcher: (intent) async {
        expect(intent.package, 'com.ichi2.anki');
        expect(intent.action, 'android.intent.action.SEND');
        expect(intent.arguments?['android.intent.extra.SUBJECT'], 'Apfel');
        expect(intent.arguments?['android.intent.extra.TEXT'], 'яблоко');
      },
    );

    final repository = AnkiRepositoryImpl(dataSource: dataSource);
    final result = await repository.addNote(front: 'Apfel', back: 'яблоко');

    expect(result.isSuccess, isTrue);
  });

  test('AnkiRepositoryImpl returns AnkiNotInstalledFailure when platform exception occurs', () async {
    final dataSource = AnkiDataSourceImpl(
      launcher: (intent) async {
        throw PlatformException(code: 'ACTIVITY_NOT_FOUND', message: 'No Activity found');
      },
    );

    final repository = AnkiRepositoryImpl(dataSource: dataSource);
    final result = await repository.addNote(front: 'Apfel', back: 'яблоко');

    expect(result.isFailure, isTrue);
    expect(result.failure, isA<AnkiNotInstalledFailure>());
  });
}
