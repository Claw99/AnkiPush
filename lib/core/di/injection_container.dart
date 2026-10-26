import 'package:get_it/get_it.dart';
import '../../features/anki/data/datasources/anki_data_source.dart';
import '../../features/anki/data/repositories/anki_repository_impl.dart';
import '../../features/anki/domain/repositories/anki_repository.dart';
import '../../features/anki/domain/usecases/add_note_to_anki_usecase.dart';
import '../../features/translator/data/datasources/translation_remote_data_source.dart';
import '../../features/translator/data/repositories/translation_repository_impl.dart';
import '../../features/translator/domain/repositories/translation_repository.dart';
import '../../features/translator/domain/usecases/get_translations_usecase.dart';
import '../../features/translator/presentation/bloc/translator_bloc.dart';
import '../network/network_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. Core
  sl.registerLazySingleton<NetworkClient>(() => NetworkClient());

  // 2. Data sources
  sl.registerLazySingleton<TranslationRemoteDataSource>(
    () => TranslationRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AnkiDataSource>(
    () => AnkiDataSourceImpl(),
  );

  // 3. Repositories
  sl.registerLazySingleton<TranslationRepository>(
    () => TranslationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AnkiRepository>(
    () => AnkiRepositoryImpl(dataSource: sl()),
  );

  // 4. Use cases
  sl.registerLazySingleton<GetTranslationsUseCase>(
    () => GetTranslationsUseCase(sl()),
  );
  sl.registerLazySingleton<AddNoteToAnkiUseCase>(
    () => AddNoteToAnkiUseCase(sl()),
  );

  // 5. BLoCs
  sl.registerFactory<TranslatorBloc>(
    () => TranslatorBloc(
      getTranslationsUseCase: sl(),
      addNoteToAnkiUseCase: sl(),
    ),
  );
}
