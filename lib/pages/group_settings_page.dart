import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sejerslev_demo/logic/group_handler.dart';
import 'package:sejerslev_demo/model/my_group.dart';
import 'package:sejerslev_demo/model/providers/select_type_provider.dart';
import 'package:sejerslev_demo/pages/add_device_page.dart';
import 'package:sejerslev_demo/pages/single_group_page.dart';
import 'package:sejerslev_demo/widgets/my_alert_dialog.dart';
import 'package:sejerslev_demo/widgets/my_dropdown_button.dart';
import 'package:sejerslev_demo/widgets/my_scrollview_w_constraints.dart';

import '../logic/tuya_handler.dart';

class GroupSettingsPage extends StatefulWidget {
  final int groupId;
  const GroupSettingsPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupSettingsPageState createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final GroupHandler _groupHandler = GroupHandler();
  final TuyaHandler _tuyaHandler = TuyaHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          // FutureBuilder<List<MyGroup>>(
          //           future: _getGroups(),
          SafeArea(
        child: FutureBuilder<MyGroup?>(
            future: _groupHandler.getGroup(widget.groupId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              MyGroup group = snapshot.data!;
              return MyConstrainedView(
                withScroll: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Flow Devices',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Spacer(),
                          // PopupMenuButton<String>(
                          //   icon: const Icon(Icons.more_horiz),
                          //   onSelected: (s) {
                          //     if (s == 'Add Device') {
                          //       goToAddDevicePage(AddDevicePage(myGroup: group), 'AddDevicePage');
                          //     }
                          //   },
                          //   itemBuilder: (BuildContext context) {
                          //     return [
                          //       const PopupMenuItem<String>(
                          //         value: 'Add Device',
                          //         child: Text('Add Device'),
                          //       ),
                          //       const PopupMenuItem<String>(
                          //         value: 'Edit Devices',
                          //         child: Text('Edit Devices'),
                          //       ),
                          //     ];
                          //   },
                          // ),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder<List<BluetoothDevice>>(
                            future: _flutterBlue.connectedDevices,
                            builder: (context, snapshot) {
                              // print('Devices: ${snapshot.data?.map((e) => e.name)}');
                              if (snapshot.hasData) {
                                var devices = snapshot.data!.where((element) => group.flowDeviceIds.contains(element.id.id)).toList();

                                if (devices.isEmpty) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: const [
                                        SizedBox(width: double.infinity, height: 20),
                                        Icon(
                                          Icons.devices,
                                          size: 140,
                                          color: Colors.grey,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'No Bluetooth Devices',
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: devices.length,
                                      itemBuilder: (context, i) {
                                        return ConnectedDeviceCard(
                                          title: devices[i].name,
                                          subtitle: devices[i].id.id,
                                          onPressed: () async {
                                            await devices[i].disconnect();
                                            await Future.delayed(const Duration(milliseconds: 100));
                                            setState(() {});
                                          },
                                          onPressed2: () async {
                                            await _groupHandler.removeFlowDeviceFromGroup(devices[i].id.id, group.id);
                                            setState(() {});
                                          },
                                        );
                                      });
                                }
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            }),
                      ),
                      const Divider(),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Energy Devices',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>?>(
                            future: _tuyaHandler.getDeviceListFromHomeId(widget.groupId),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var devices = snapshot.data!.where((element) => group.energyDeviceIds.contains(element['devId'])).toList();

                                if (devices.isEmpty) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      children: const [
                                        SizedBox(width: double.infinity, height: 20),
                                        Icon(
                                          Icons.devices,
                                          size: 140,
                                          color: Colors.grey,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('No Energy Devices'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: devices.length,
                                      itemBuilder: (context, i) {
                                        // print('${devices[i].name}');
                                        return ConnectedDeviceCard(
                                          title: devices[i]['name'],
                                          subtitle: devices[i]['devId'],
                                          onPressed: () async {
                                            await _groupHandler.removeEnergyDeviceFromGroup(devices[i]['devId'], group.id);

                                            setState(() {});
                                          },
                                        );
                                      });
                                }
                              } else {
                                return const Center(child: CircularProgressIndicator());
                              }
                            }),
                      ),
                      const Divider(),
                      Card(
                        child: ListTile(
                          title: const Text('Temperature Unit'),
                          trailing: PopupMenuButton<TemperatureUnit>(
                            child: SizedBox(
                              width: 150,
                              height: double.infinity,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text('${group.temperatureUnit.name[0].toUpperCase()}${group.temperatureUnit.name.substring(1)}'),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                            onSelected: (value) async {
                              var newGroup = group;
                              if (value == TemperatureUnit.celsius && newGroup.temperatureUnit != TemperatureUnit.celsius) {
                                newGroup.temperatureUnit = TemperatureUnit.celsius;
                              } else if (newGroup.temperatureUnit != TemperatureUnit.fahrenheit) {
                                newGroup.temperatureUnit = TemperatureUnit.fahrenheit;
                              } else {
                                return;
                              }
                              await _groupHandler.editGroup(newGroup);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                const PopupMenuItem<TemperatureUnit>(
                                  value: TemperatureUnit.celsius,
                                  child: Text('Celsius'),
                                ),
                                const PopupMenuItem<TemperatureUnit>(
                                  value: TemperatureUnit.fahrenheit,
                                  child: Text('Fahrenheit'),
                                ),
                              ];
                            },
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          onTap: () async {
                            await _tuyaHandler.removeHome(group.id, () async {
                              await _groupHandler.deleteGroup(group.id);
                              if (mounted) {
                                showMyDialog(context, 'Success', message: 'Group has been removed').then((value) {
                                  if (mounted) {
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                  }
                                });
                              }
                            }, (message) {
                              if (mounted) {
                                showMyDialog(context, 'Error', message: message);
                              }
                            });
                          },
                          title: const Text('Delete Group'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }

  Future<dynamic> goToAddDevicePage(Widget route, String settingsName, int index) async {
    String? deviceId = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevicePage(groupId: widget.groupId, index: index)));
    if (deviceId != null) {
      setState(() {});
    }
  }
}

class ConnectedDeviceCard extends StatelessWidget {
  // final BluetoothDevice device;
  final String title;
  final String subtitle;
  final void Function() onPressed;
  final void Function()? onPressed2;
  const ConnectedDeviceCard({
    Key? key,
    // required this.device,
    required this.onPressed,
    this.onPressed2,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // color: Colors.blue,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        // onTap: () => goToPageWithSetState(SingleGroupPage(myGroup: devices[i]), 'SingleGroupPage'),
        // onTap: () => goToDeviceServices(devices[i]),
        child: Row(
          children: [
            const SizedBox(width: 16),
            // Icon(
            //   devices[i].leading == GroupWidget.indoor ? Icons.house_rounded : Icons.cloud,
            //   size: 35,
            // ),
            // const SizedBox(width: 10),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   devices[i].title,
                  //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  // Text(
                  //   '${devices[i].subtitle} klsad',
                  //   style: const TextStyle(color: Colors.white70),
                  // ),

                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            )),
            const SizedBox(width: 10),
            onPressed2 != null
                ? IconButton(
                    onPressed: onPressed2,
                    icon: const Icon(Icons.remove_circle_rounded),
                    color: Colors.red,
                  )
                : const SizedBox.shrink(),
            const SizedBox(width: 10),
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.link_off),
              color: Colors.red,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
