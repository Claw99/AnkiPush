import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';
import '../../../../core/error/exceptions.dart';

abstract class AnkiDataSource {
  Future<void> sendNoteIntent({required String front, required String back});
}

typedef IntentLauncher = Future<void> Function(AndroidIntent intent);

class AnkiDataSourceImpl implements AnkiDataSource {
  final IntentLauncher _launcher;

  AnkiDataSourceImpl({IntentLauncher? launcher})
      : _launcher = launcher ?? _defaultLauncher;

  static Future<void> _defaultLauncher(AndroidIntent intent) async {
    await intent.launch();
  }

  @override
  Future<void> sendNoteIntent({required String front, required String back}) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.SEND',
      package: 'com.ichi2.anki',
      type: 'text/plain',
      arguments: <String, dynamic>{
        'android.intent.extra.SUBJECT': front,
        'android.intent.extra.TEXT': back,
      },
    );

    try {
      await _launcher(intent);
    } on PlatformException catch (e) {
      throw AnkiNotInstalledException(
        'Приложение AnkiDroid не найдено на устройстве: ${e.message}',
      );
    } catch (e) {
      if (e is AnkiNotInstalledException) rethrow;
      throw AnkiNotInstalledException(
        'Приложение AnkiDroid не найдено или не может быть открыто ($e)',
      );
    }
  }
}
