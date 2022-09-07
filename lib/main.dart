import '/pages/connected_bt_devices.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/providers/loading_provider.dart';

void main() {
  // runApp(FlutterBlueApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LoadingProvider>(create: (context) => LoadingProvider()),
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
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
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
      home: const GroupListPage(),
    );
  }
}
