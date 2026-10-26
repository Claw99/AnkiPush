import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/translator/presentation/bloc/translator_bloc.dart';
import 'features/translator/presentation/pages/translator_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const AnkiPushApp());
}

class AnkiPushApp extends StatelessWidget {
  const AnkiPushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkiPush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: BlocProvider(
        create: (_) => sl<TranslatorBloc>(),
        child: const TranslatorPage(),
      ),
    );
  }
}
