import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sejerslev_demo/logic/file_handler.dart';

import '../model/my_group.dart';
import '../model/providers/loading_provider.dart';
import '../model/providers/type_with_notify.dart';
import '../widgets/my_alert_dialog.dart';

class AddDevicePage extends StatefulWidget {
  final MyGroup myGroup;
  const AddDevicePage({Key? key, required this.myGroup}) : super(key: key);

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  Timer? _timer;
  FileHandler _fileHandler = FileHandler();

  Future<void> _findPrinters() async {
    // Start scanning

    await flutterBlue.startScan(timeout: const Duration(seconds: 5));
  }

  @override
  void initState() {
    _findPrinters();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void initialLoading(BuildContext context) async {
    var boolsWithNotify = context.read<BoolsWithNotify>();
    _timer = Timer(const Duration(seconds: 4), () {
      boolsWithNotify.setValue(0, false);
    });
    // Future.delayed(const Duration(seconds: 4), () => boolsWithNotify.setValue(0, false));
  }

  Future<void> addDeviceToGroup(String deviceId) async {
    String jsonString = await _fileHandler.readFile(JsonFileName.groupsJsonFile);

    List<dynamic> jsonData = jsonDecode(jsonString);
    List<MyGroup> groups = jsonData.map<MyGroup>((e) => MyGroup.fromJson(e)).toList();

    int groupIndex = groups.indexWhere((element) => element.id == widget.myGroup.id);
    if (groupIndex != -1 && !groups[groupIndex].deviceIds.contains(deviceId)) {
      groups[groupIndex].deviceIds.add(deviceId);
      await _fileHandler.writeFile(JsonFileName.groupsJsonFile, jsonEncode(groups));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoolsWithNotify>(
      create: (context) => BoolsWithNotify([true]),
      builder: (context, child) {
        initialLoading(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Connect'),
            actions: [
              SizedBox(
                height: 50,
                width: 50,
                child: Consumer<BoolsWithNotify>(
                  builder: (context, value, child) {
                    if (value.bools[0]) {
                      return const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            )),
                      );
                    } else {
                      return IconButton(
                          onPressed: () async {
                            var boolsWithNotify = context.read<BoolsWithNotify>();
                            boolsWithNotify.setValue(0, true);
                            await flutterBlue.stopScan();
                            await Future.delayed(
                                const Duration(
                                  milliseconds: 300,
                                ), () {
                              return _findPrinters();
                            });
                            if (mounted) {
                              boolsWithNotify.setValue(0, false);
                            }
                          },
                          icon: const Icon(Icons.refresh));
                    }
                  },
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      FutureBuilder<List<BluetoothDevice>>(
                        future: flutterBlue.connectedDevices,
                        builder: (context, connectedSnapshot) {
                          if (connectedSnapshot.hasData) {
                            if (connectedSnapshot.data!.isEmpty) {
                              return Center(
                                child: Text('data'),
                              );
                              // return SizedBox.shrink();
                            } else {
                              return Column(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: Text('Select from connected devices',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white60)),
                                  ),
                                  ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: connectedSnapshot.data!.length,
                                      itemBuilder: (context, i) {
                                        return DeviceConnectCard(
                                            title: connectedSnapshot.data![i].name,
                                            subtitle: connectedSnapshot.data![i].id.id,
                                            onPressed: () {
                                              addDeviceToGroup(connectedSnapshot.data![i].id.id);
                                              showMyDialog(
                                                context,
                                                'Device Added',
                                                'The device has been added to the group.',
                                              ).then((value) => Navigator.pop(context, connectedSnapshot.data![i].id.id));
                                            });
                                        // return Card(
                                        //   clipBehavior: Clip.hardEdge,
                                        //   child: InkWell(
                                        //     onTap: () {},
                                        //     child: Row(
                                        //       children: [
                                        //         const SizedBox(width: 16),
                                        //         Expanded(
                                        //             child: Padding(
                                        //           padding: const EdgeInsets.symmetric(vertical: 20.0),
                                        //           child: Column(
                                        //             crossAxisAlignment: CrossAxisAlignment.start,
                                        //             children: [
                                        //               Text(
                                        //                 snapshot.data![i].name,
                                        //                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        //               ),
                                        //               Text(
                                        //                 '${snapshot.data![i].id}',
                                        //                 style: const TextStyle(color: Colors.white70),
                                        //               ),
                                        //             ],
                                        //           ),
                                        //         )),
                                        //         const SizedBox(width: 10),
                                        //         const Padding(
                                        //           padding: EdgeInsets.all(4.0),
                                        //           child: CircleAvatar(
                                        //               radius: 18,
                                        //               backgroundColor: Colors.black,
                                        //               foregroundColor: Colors.white,
                                        //               child: Icon(Icons.electric_bolt_rounded)),
                                        //         ),
                                        //         const SizedBox(width: 16),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // );
                                      }),
                                ],
                              );
                            }
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                      FutureBuilder<bool>(
                          future: Future.delayed(const Duration(microseconds: 500), () => true),
                          builder: (context, delaySnapshot) {
                            if (delaySnapshot.data ?? false) {
                              return StreamBuilder<List<ScanResult>>(
                                stream: flutterBlue.scanResults,
                                builder: (context, scanSnapshot) {
                                  if (scanSnapshot.hasData) {
                                    // var scanResults = scanSnapshot.data!.where((element) => element.device.name.isNotEmpty).toList();
                                    var scanResults = scanSnapshot.data!.where((element) => element.device.name.contains('FloPro')).toList();
                                    // var scanResults = scanSnapshot.data!.where((element) => element.device.type != BluetoothDeviceType.unknown).toList();
                                    scanResults.sort((a, b) =>
                                        a.device.name.isEmpty ? 1 : a.device.name.compareTo(b.device.name.isEmpty ? 'zzzzz' : b.device.name));
                                    // print(scanResults.map((e) => e.device.name.isEmpty ? '...' : e.device.name));

                                    return Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: Text('Select a bluetooth device',
                                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white60)),
                                        ),
                                        scanResults.isEmpty
                                            ? const Center(child: Text('Ingen enheder fundet.'))
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return DeviceConnectCard(
                                                    title: scanResults[index].device.name,
                                                    subtitle: scanResults[index].device.id.id,
                                                    onPressed: () async {
                                                      if (!scanResults[index].device.name.contains('FloPro')) {
                                                        showMyDialog(
                                                          context,
                                                          'Device Incompatible',
                                                          'Please choose a FloPro device.',
                                                        );
                                                        return;
                                                      }
                                                      var deviceState = await scanResults[index].device.state.first;
                                                      if (deviceState == BluetoothDeviceState.connected && mounted) {
                                                        showMyDialog(
                                                          context,
                                                          'Failed',
                                                          'Device is already connected.',
                                                        );
                                                        return;
                                                      }
                                                      // var loadingProvider = context.read<LoadingProvider>();
                                                      // loadingProvider.setLoading(true);
                                                      showMyLoadingDialog(context);
                                                      // scanResults[index].device.connect(timeout: const Duration(seconds: 2));

                                                      bool? returnValue;
                                                      String dialogTitle = '';
                                                      String dialogMessage = '';

                                                      try {
                                                        await scanResults[index]
                                                            .device
                                                            .connect(autoConnect: false)
                                                            .timeout(const Duration(seconds: 10), onTimeout: () {
                                                          debugPrint('timeout occured');
                                                          dialogTitle = 'Error';
                                                          dialogMessage = 'Couldn\'t connect.\nTimed out.';
                                                          returnValue = false;
                                                          scanResults[index].device.disconnect();
                                                        }).then((data) {
                                                          if (returnValue == null) {
                                                            dialogTitle = 'Success';
                                                            dialogMessage = 'Connected to device!';
                                                            debugPrint('connection successful');
                                                            returnValue = true;
                                                          }
                                                          // loadingProvider.setLoading(false);
                                                        });
                                                      } on PlatformException catch (e) {
                                                        // loadingProvider.setLoading(false);

                                                        if (e.code == 'already_connected') {
                                                          dialogTitle = 'Failed';
                                                          dialogMessage = 'Device is already connected.';
                                                        } else {
                                                          dialogTitle = 'Error';
                                                          dialogMessage = e.code;
                                                        }
                                                      }

                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                        if (returnValue ?? false) {
                                                          addDeviceToGroup(scanResults[index].device.id.id);
                                                          showMyDialog(
                                                            context,
                                                            dialogTitle,
                                                            dialogMessage,
                                                            // infoDialog: false,
                                                            // onlyAction: true,
                                                            // myOnPressed: () =>
                                                            //     Navigator.popUntil(context, (route) => route.settings.name == 'SingleGroupPage'),
                                                          ).then((value) => Navigator.pop(context, scanResults[index].device.id.id));
                                                        } else {
                                                          showMyDialog(
                                                            context,
                                                            dialogTitle,
                                                            dialogMessage,
                                                          );
                                                        }
                                                      }
                                                    },
                                                  );
                                                  // return Card(
                                                  //   child: InkWell(
                                                  //     onTap: () async {},
                                                  //     child: Padding(
                                                  //       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
                                                  //       child: Row(
                                                  //         mainAxisSize: MainAxisSize.min,
                                                  //         children: [
                                                  //           // Padding(
                                                  //           //   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25),
                                                  //           //   child: Icon(Icons.webhook_outlined),
                                                  //           // ),
                                                  //           Expanded(
                                                  //             child: Column(
                                                  //               crossAxisAlignment: CrossAxisAlignment.start,
                                                  //               children: [
                                                  //                 Text(
                                                  //                   scanResults[index].device.name.isEmpty ? '....' : scanResults[index].device.name,
                                                  //                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                  //                 ),
                                                  //                 Text(
                                                  //                   scanResults[index].device.id.id,
                                                  //                   style: const TextStyle(color: Colors.white54, fontSize: 11),
                                                  //                 ),
                                                  //               ],
                                                  //             ),
                                                  //           ),
                                                  //           const SizedBox(width: 5),
                                                  //           const Icon(
                                                  //             Icons.link,
                                                  //             color: Colors.blue,
                                                  //           ),
                                                  //           const SizedBox(width: 20),
                                                  //         ],
                                                  //       ),
                                                  //     ),
                                                  //   ),
                                                  // );
                                                },
                                                itemCount: scanResults.length,
                                              ),
                                      ],
                                    );
                                  }
                                  // print('scansnapsghot: ${scanSnapshot.data}');
                                  else if (scanSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  } else {
                                    return const Center(child: Text('Error'));
                                  }
                                },
                              );
                            } else {
                              return const Center(child: CircularProgressIndicator());
                            }
                          }),
                    ],
                  ),
                ),
              ),
              Consumer<LoadingProvider>(
                builder: (context, value, child) {
                  if (value.isLoading) {
                    return Container(color: Colors.black54, child: const Center(child: CircularProgressIndicator()));
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class DeviceConnectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final void Function() onPressed;
  const DeviceConnectCard({Key? key, required this.title, required this.subtitle, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 25),
              //   child: Icon(Icons.webhook_outlined),
              // ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? '....' : title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.link,
                color: Colors.blue,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
    ;
  }
}
