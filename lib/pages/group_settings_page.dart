import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sejerslev_demo/logic/group_handler.dart';
import 'package:sejerslev_demo/model/my_group.dart';
import 'package:sejerslev_demo/model/providers/select_type_provider.dart';
import 'package:sejerslev_demo/pages/add_device_page.dart';
import 'package:sejerslev_demo/pages/single_group_page.dart';
import 'package:sejerslev_demo/widgets/my_dropdown_button.dart';
import 'package:sejerslev_demo/widgets/my_scrollview_w_constraints.dart';

class GroupSettingsPage extends StatefulWidget {
  final MyGroup myGroup;
  const GroupSettingsPage({Key? key, required this.myGroup}) : super(key: key);

  @override
  _GroupSettingsPageState createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final GroupHandler _groupHandler = GroupHandler();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:
          // FutureBuilder<List<MyGroup>>(
          //           future: _getGroups(),
          SafeArea(
        child: MyConstrainedView(
          withScroll: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Devices',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    // PopupMenuButton<String>(
                    //   icon: const Icon(Icons.more_horiz),
                    //   onSelected: (s) {
                    //     if (s == 'Add Device') {
                    //       goToAddDevicePage(AddDevicePage(myGroup: widget.myGroup), 'AddDevicePage');
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
                          var devices = snapshot.data!.where((element) => widget.myGroup.flowDeviceIds.contains(element.id.id)).toList();

                          if (devices.isEmpty) {
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(width: double.infinity, height: 20),
                                  const Icon(
                                    Icons.devices,
                                    size: 140,
                                    color: Colors.grey,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      'No devices',
                                      // style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(16.0),
                                  //   child: ElevatedButton(
                                  //     onPressed: () async {
                                  //       // await goToPageWithSetState(AddDevicePage(myGroup: widget.myGroup), 'AddDevicePage');
                                  //       await goToAddDevicePage(AddDevicePage(myGroup: widget.myGroup, index: 0), 'AddDevicePage');
                                  //     },
                                  //     child: const Text('Add Devices'),
                                  //   ),
                                  // ),
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
                                      device: devices[i],
                                      onPressed: () async {
                                        await devices[i].disconnect();
                                        await Future.delayed(const Duration(milliseconds: 100));
                                        setState(() {});
                                      });
                                  // return Card(
                                  //   // color: Colors.blue,
                                  //   clipBehavior: Clip.hardEdge,
                                  //   child: InkWell(
                                  //     // onTap: () => goToPageWithSetState(SingleGroupPage(myGroup: devices[i]), 'SingleGroupPage'),
                                  //     // onTap: () => goToDeviceServices(devices[i]),
                                  //     child: Row(
                                  //       children: [
                                  //         const SizedBox(width: 16),
                                  //         // Icon(
                                  //         //   devices[i].leading == GroupWidget.indoor ? Icons.house_rounded : Icons.cloud,
                                  //         //   size: 35,
                                  //         // ),
                                  //         // const SizedBox(width: 10),
                                  //         Expanded(
                                  //             child: Padding(
                                  //           padding: const EdgeInsets.symmetric(vertical: 20.0),
                                  //           child: Column(
                                  //             crossAxisAlignment: CrossAxisAlignment.start,
                                  //             children: [
                                  //               // Text(
                                  //               //   devices[i].title,
                                  //               //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  //               // ),
                                  //               // Text(
                                  //               //   '${devices[i].subtitle} klsad',
                                  //               //   style: const TextStyle(color: Colors.white70),
                                  //               // ),

                                  //               Text(
                                  //                 devices[i].name,
                                  //                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  //               ),
                                  //               Text(
                                  //                 devices[i].id.id,
                                  //                 style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         )),
                                  //         const SizedBox(width: 10),
                                  //         IconButton(
                                  //           onPressed: () async {
                                  //             await devices[i].disconnect();
                                  //             await Future.delayed(const Duration(milliseconds: 100));
                                  //             setState(() {});
                                  //           },
                                  //           icon: const Icon(Icons.link_off),
                                  //           color: Colors.red,
                                  //         ),
                                  //         const SizedBox(width: 16),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // );
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
                    title: Text('Temperature Unit'),
                    trailing: PopupMenuButton<TemperatureUnit>(
                      // icon: const Icon(Icons.more_horiz),
                      child: SizedBox(
                        width: 150,
                        height: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${widget.myGroup.temperatureUnit.name[0].toUpperCase()}${widget.myGroup.temperatureUnit.name.substring(1)}'),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      onSelected: (value) async {
                        var newGroup = widget.myGroup;
                        if (value == TemperatureUnit.celsius && newGroup.temperatureUnit != TemperatureUnit.celsius) {
                          newGroup.temperatureUnit = TemperatureUnit.celsius;
                        } else if (newGroup.temperatureUnit != TemperatureUnit.fahrenheit) {
                          newGroup.temperatureUnit = TemperatureUnit.fahrenheit;
                        } else {
                          return;
                        }
                        await _groupHandler.editGroup(newGroup);
                        if (mounted) {
                          setState(() {
                            widget.myGroup.temperatureUnit = value;
                          });
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
                      await _groupHandler.deleteGroup(widget.myGroup.id);
                      if (mounted) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                    title: const Text('Delete Group'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> goToAddDevicePage(Widget route, String settingsName, int index) async {
    String? deviceId = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevicePage(myGroup: widget.myGroup, index: index)));
    if (deviceId != null) {
      widget.myGroup.flowDeviceIds[index] = deviceId;
    }
  }
}

class ConnectedDeviceCard extends StatelessWidget {
  final BluetoothDevice device;
  final void Function() onPressed;
  const ConnectedDeviceCard({Key? key, required this.device, required this.onPressed}) : super(key: key);

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
                    device.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    device.id.id,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            )),
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
