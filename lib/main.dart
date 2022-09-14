import 'package:sejerslev_demo/logic/auth_app_state.dart';
import 'package:sejerslev_demo/pages/authentication/check_login_page.dart';

import 'logic/tuya_handler.dart';
import 'pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/providers/loading_provider.dart';

void main() {
  // runApp(FlutterBlueApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoadingProvider>(create: (context) => LoadingProvider()),
        ChangeNotifierProvider<AuthAppState>(create: (context) => AuthAppState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(10)),
          ),
          popupMenuTheme: PopupMenuThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          cardTheme: CardTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all<Size>(const Size(120, 50)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Colors.blue, foregroundColor: Colors.white)),
      // home: const MyHomePage(),
      home: const CheckLoginPage(),
    );
  }
}
