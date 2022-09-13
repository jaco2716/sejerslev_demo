import 'dart:convert';

import 'package:gauges/gauges.dart';
import 'package:sejerslev_demo/logic/auth_app_state.dart';
import 'package:sejerslev_demo/logic/file_handler.dart';
import 'package:sejerslev_demo/model/my_group.dart';
import 'package:sejerslev_demo/pages/create_group_page.dart';
import 'package:sejerslev_demo/widgets/my_alert_dialog.dart';

import '../widgets/my_scrollview_w_constraints.dart';
import '/model/providers/loading_provider.dart';
import 'scan_bt_devices.dart';
import 'single_group_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final FileHandler _fileHandler = FileHandler();

  Future<List<MyGroup>> _getGroups() async {
    String jsonString = await _fileHandler.readFile(JsonFileName.groupsJsonFile);
    if (jsonString.isEmpty) {
      return [];
    } else {
      List<dynamic> jsonData = jsonDecode(jsonString);
      List<MyGroup> groups = jsonData.map<MyGroup>((e) => MyGroup.fromJson(e)).toList();
      return groups;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              showMyDialog(context, 'Menu',
                  cancelText: 'Close',
                  widgetContent: Column(
                    children: [
                      const Text('Do you wish to log out?'),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () {
                              context.read<AuthAppState>().logOutUser(() {
                                Navigator.pop(context);
                              }, (message) {
                                showMyDialog(context, 'Error', message: message);
                              });
                            },
                            child: const Text('Log out')),
                      )
                    ],
                  ));
            },
            icon: const Icon(Icons.menu)),
        toolbarHeight: 110,
        // elevation: 1,
        backgroundColor: Colors.grey[900],
        title: SizedBox(
          height: 80,
          child: Image.asset('assets/logo/logo_light.png'),
        ),
        // title: SizedBox(
        //   width: double.infinity,
        //   child: Align(alignment: Alignment.centerRight, child: Text('Add group')),
        // ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => goToPageWithSetState(const CreateGroupPage(), 'CreateGroupPage'),
                child: Row(
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Add',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.add),
                    ),
                    // SizedBox(width: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: IconButton(
      //     icon: Icon(Icons.add),
      //     onPressed: () {},
      //   ),
      // ),
      body: MyConstrainedView(
        withScroll: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'All Groups',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  )
                  // TextButton(onPressed: () {}, child: Text('...', style: Textst,))
                ],
              ),
              // ElevatedButton(
              //     onPressed: () {
              //       // context.read<BoolsWithNotify>().setValue(0, true);
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => const ScanBtDevices(),
              //           )).then((value) {
              //         context.read<LoadingProvider>().setLoading(false);

              //         setState(() {});
              //       });
              //     },
              //     child: const Text('Connect Devices')),
              Expanded(
                child: FutureBuilder<List<MyGroup>>(
                    future: _getGroups(),
                    // FutureBuilder<List<BluetoothDevice>>(
                    //     future: flutterBlue.connectedDevices,
                    builder: (context, snapshot) {
                      // print('Devices: ${snapshot.data?.map((e) => e.name)}');
                      if (snapshot.hasData) {
                        if (snapshot.data!.isEmpty) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(width: double.infinity, height: 20),
                                const Icon(
                                  Icons.widgets_rounded,
                                  size: 140,
                                  color: Colors.grey,
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'No groups',
                                    // style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: ElevatedButton(
                                      onPressed: () => goToPageWithSetState(const CreateGroupPage(), 'CreateGroupPage'),
                                      child: const Text('Add Group')),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return ListView.builder(
                              // shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, i) {
                                // print('${snapshot.data![i].name}');
                                return Card(
                                  // color: Colors.blue,
                                  clipBehavior: Clip.hardEdge,
                                  child: InkWell(
                                    onTap: () => goToPageWithSetState(SingleGroupPage(groupId: snapshot.data![i].id), 'SingleGroupPage'),
                                    // onTap: () => goToDeviceServices(snapshot.data![i]),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 16),
                                        Icon(
                                          snapshot.data![i].groupCategory == GroupCategory.indoor ? Icons.house_rounded : Icons.cloud,
                                          size: 25,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot.data![i].title,
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                snapshot.data![i].description,
                                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                                              ),
                                              // Row(
                                              //   children: [
                                              //     Icon(Icons.ice_skating_rounded),
                                              //     Icon(Icons.settings),
                                              //     Icon(Icons.settings),
                                              //   ],
                                              // )
                                              // Text(
                                              //   snapshot.data![i].name,
                                              //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              // ),
                                              // Text(
                                              //   snapshot.data![i].id.id,
                                              //   style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              // ),
                                            ],
                                          ),
                                        )),
                                        // const Icon(Icons.insert_chart_outlined_rounded, color: Colors.blue),
                                        const SizedBox(width: 10),
                                        const Padding(
                                          padding: EdgeInsets.all(2.0),
                                          child: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              child: Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: FittedBox(child: Icon(Icons.electric_bolt_rounded)),
                                              )),
                                        ),
                                        const MiniGauge(),
                                        const MiniGauge(),
                                        // IconButton(
                                        //   onPressed: () async {},
                                        //   icon: const Icon(Icons.insert_chart_outlined_rounded),
                                        //   color: Colors.blue,
                                        // ),
                                        // IconButton(
                                        //   onPressed: () async {
                                        //     List<BluetoothService> services = await snapshot.data![i].discoverServices();
                                        //     if (mounted) {
                                        //       Navigator.push(context, MaterialPageRoute(builder: (context) => DeviceServicesPage(services: services)));
                                        //     }
                                        //   },
                                        //   icon: const Icon(Icons.settings),
                                        //   color: Colors.blue,
                                        // ),
                                        // IconButton(
                                        //   onPressed: () async {},
                                        //   icon: const Icon(Icons.settings),
                                        //   // color: Colors.red,
                                        // ),
                                        // IconButton(
                                        //   onPressed: () async {
                                        //     await snapshot.data![i].disconnect();
                                        //     await Future.delayed(const Duration(milliseconds: 100));
                                        //     setState(() {});
                                        //   },
                                        //   icon: const Icon(Icons.link_off),
                                        //   color: Colors.red,
                                        // ),
                                        const SizedBox(width: 16),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> goToPageWithSetState(Widget route, String settingsName) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => route, settings: RouteSettings(name: settingsName))).then((value) {
      setState(() {});
    });
  }

  // goToDeviceServices(BluetoothDevice device) async {
  //   // showMyDialog(context, '', '', widgetContent: const Center(child: CircularProgressIndicator()));
  //   showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));
  //   List<BluetoothService> services = await device.discoverServices();
  //   if (mounted) {
  //     Navigator.pop(context);
  //     Navigator.push(context, MaterialPageRoute(builder: (context) => SingleReaderPage(title: device.name, services: services)));
  //   }
  // }
}

class MiniGauge extends StatelessWidget {
  const MiniGauge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      height: 32,
      width: 32,
      child: RadialGauge(
        axes: [
          RadialGaugeAxis(
            minValue: 0,
            maxValue: 10,
            width: 0.4,
            color: Colors.transparent,
            pointers: [
              RadialNeedlePointer(
                value: 5,
                thicknessStart: 4,
                thicknessEnd: 1,
                length: 1,
                knobRadiusAbsolute: 2,
                color: Colors.white,
                knobColor: Colors.white,
              )
            ],
            segments: const [
              RadialGaugeSegment(
                minValue: 0,
                maxValue: 0,
                minAngle: -150,
                maxAngle: -50,
                color: Colors.white,
              ),
              RadialGaugeSegment(
                minValue: 0,
                maxValue: 0,
                minAngle: -50,
                maxAngle: 50,
                color: Colors.blue,
              ),
              RadialGaugeSegment(
                minValue: 0,
                maxValue: 0,
                minAngle: 50,
                maxAngle: 150,
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
