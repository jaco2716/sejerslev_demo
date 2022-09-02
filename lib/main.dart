import 'package:flutter/services.dart';

import '/connected_bt_devices.dart';
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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  static const platform = const MethodChannel("dk.wejeo.sejerslev_demo/tuya");

  Future _loadSurveyMonkey() async {
    try {
      await platform.invokeMethod('surveyMonkey', sessionSurveyMonkeyHash).then((result) {
        print(result);
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(),
      home: const Scaffold(
        // appBar: AppBar(
        //   title: Text('Demo'),
        // ),
        // body: MyHomePage(),
        body: ConnectedBtDevices(),
      ),
    );
  }
}
