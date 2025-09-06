import 'package:flutter/material.dart';
//Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Router
import 'package:english_learning_app/app/routes/app_routes.dart';
// Easy localization
import 'package:easy_localization/easy_localization.dart';
//Redux
import 'package:flutter_redux/flutter_redux.dart';
import 'package:english_learning_app/app/core/redux/app_state.dart';
import 'package:english_learning_app/app/core/redux/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo easy_localization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VI')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: StoreProvider<AppState>(store: store, child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // Title theo đa ngôn ngữ
      onGenerateTitle: (context) => "app_title".tr(),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lime),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightGreen,
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),

      // Hỗ trợ đa ngôn ngữ
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      routerConfig: router,
    );
  }
}
