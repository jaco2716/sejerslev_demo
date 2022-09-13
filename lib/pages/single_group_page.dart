import 'dart:typed_data';
import '../device_test_page.dart';
import '/logic/group_handler.dart';
import '/logic/tuya_handler.dart';
import '/logic/validate_values.dart';
import '/model/my_group.dart';
import '/pages/add_device_page.dart';
import '/pages/group_settings_page.dart';
import '/widgets/my_alert_dialog.dart';
import '/widgets/my_count_down.dart';
import '/widgets/my_text_field.dart';
import '../widgets/icon_with_ation.dart';
import '../widgets/single_energy_device.dart';
import '../widgets/single_flopro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum CharacteristicName {
  pressure,
  barometer,
  flow,
  temperature,
  time,
}

class SingleGroupPage extends StatefulWidget {
  // final List<BluetoothService> services;
  final int groupId;

  // final String title;
  const SingleGroupPage({
    Key? key,
    required this.groupId,
    // required this.title,
    // required this.services,
  }) : super(key: key);

  @override
  State<SingleGroupPage> createState() => _SingleGroupPageState();
}

class _SingleGroupPageState extends State<SingleGroupPage> {
  // bool isOn = true;
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final GroupHandler _groupHandler = GroupHandler();
  final TuyaHandler _tuyaHandler = TuyaHandler();
  Future<bool?> isLoading = Future.value(null);
  BluetoothService? dataService;
  BluetoothService? timeService;
  Map<String, Map<CharacteristicName, BluetoothCharacteristic?>> characteristics = {};
  // BluetoothCharacteristic? pressureCharacteristic;
  // BluetoothCharacteristic? barometerCharacteristic;
  // BluetoothCharacteristic? flowCharacteristic;
  // BluetoothCharacteristic? temperatureCharacteristic;
  // BluetoothCharacteristic? timeCharacteristic;
  List<List<int>> dateData = [];
  bool isNotifying = true;
  List<BluetoothDevice> devices = [];

  MyGroup? group;

  Future<MyGroup?> updateGroup() async {
    group = await _groupHandler.getGroup(widget.groupId);
    return group;
  }

  Future<Map<String, List<BluetoothService>>> getBTDeviceServices() async {
    Map<String, List<BluetoothService>> devicesServies = {};
    devices = await _flutterBlue.connectedDevices;
    await updateGroup();
    for (var device in devices) {
      if (group?.flowDeviceIds.contains(device.id.id) ?? false) {
        var tempService = await device.discoverServices();
        devicesServies[device.id.id] = tempService;
      }
    }
    return devicesServies;
  }

  Future<void> setupService() async {
    var devicesServies = await getBTDeviceServices();
    if (devicesServies.isEmpty) {
      if (mounted) {
        setState(() {
          isLoading = Future.value(false);
        });
      }
      return;
    }
    for (var deviceId in devicesServies.keys) {
      characteristics[deviceId] = {};

      //Time setup
      int timeServiceIndex = devicesServies[deviceId]!.indexWhere((element) => element.uuid.toString() == '00001805-0000-1000-8000-00805f9b34fb');
      if (timeServiceIndex != -1) timeService = devicesServies[deviceId]![timeServiceIndex];
      int timeIndex = timeService?.characteristics.indexWhere((element) => element.uuid.toString() == '00002a2b-0000-1000-8000-00805f9b34fb') ?? -1;
      if (timeIndex != -1) characteristics[deviceId]?[CharacteristicName.time] = timeService?.characteristics[timeIndex];
      // if (timeIndex != -1) timeCharacteristic = timeService?.characteristics[timeIndex];

      //Service setup
      int serviceIndex = devicesServies[deviceId]!.indexWhere((element) => element.uuid.toString() == '8d8cceb9-ec48-4621-b293-0bafb0e0fa2d');
      if (serviceIndex != -1) dataService = devicesServies[deviceId]![serviceIndex];
      int pressureIndex =
          dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '3300c0b5-2369-4322-8296-5564f44850b3') ?? -1;
      if (pressureIndex != -1) characteristics[deviceId]?[CharacteristicName.pressure] = dataService?.characteristics[pressureIndex];
      // if (pressureIndex != -1) pressureCharacteristic = dataService?.characteristics[pressureIndex];
      int barometerIndex =
          dataService?.characteristics.indexWhere((element) => element.uuid.toString() == 'c6ae9dac-5cfe-43cc-9c24-cbcf6e48e820') ?? -1;
      if (barometerIndex != -1) characteristics[deviceId]?[CharacteristicName.barometer] = dataService?.characteristics[barometerIndex];
      // if (barometerIndex != -1) barometerCharacteristic = dataService?.characteristics[barometerIndex];
      // int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '951770bd-a550-4466-b16f-4bc3170f4d0e');
      int flowIndex = dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '7cb8e55f-d785-4c62-b6f7-ba6ba7581b7b') ?? -1;
      if (flowIndex != -1) characteristics[deviceId]?[CharacteristicName.flow] = dataService?.characteristics[flowIndex];
      // if (flowIndex != -1) flowCharacteristic = dataService?.characteristics[flowIndex];
      int temperatureIndex =
          dataService?.characteristics.indexWhere((element) => element.uuid.toString() == 'f3d4b10d-7485-4945-a849-162d8acc1f42') ?? -1;
      if (temperatureIndex != -1) characteristics[deviceId]?[CharacteristicName.temperature] = dataService?.characteristics[temperatureIndex];
      // if (temperatureIndex != -1) temperatureCharacteristic = dataService?.characteristics[temperatureIndex];

      var timeValue = await characteristics[deviceId]?[CharacteristicName.time]?.read();
      // var timeValue = await timeCharacteristic?.read();
      if (timeValue != null) {
        var bytes = Uint8List.fromList(timeValue);
        var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
        DateTime deviceDate = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
        var dateNow = DateTime.now();
        if (dateNow.difference(deviceDate).inMinutes > 2) {
          await setDeviceTime(deviceId);
        }
      }
      await characteristics[deviceId]?[CharacteristicName.time]?.setNotifyValue(isNotifying);
      await characteristics[deviceId]?[CharacteristicName.pressure]?.setNotifyValue(isNotifying);
      await characteristics[deviceId]?[CharacteristicName.barometer]?.setNotifyValue(isNotifying);
      await characteristics[deviceId]?[CharacteristicName.flow]?.setNotifyValue(isNotifying);
      await characteristics[deviceId]?[CharacteristicName.temperature]?.setNotifyValue(isNotifying);
    }
    // await timeCharacteristic?.setNotifyValue(isNotifying);
    // await pressureCharacteristic?.setNotifyValue(isNotifying);
    // await barometerCharacteristic?.setNotifyValue(isNotifying);
    // await flowCharacteristic?.setNotifyValue(isNotifying);
    // await temperatureCharacteristic?.setNotifyValue(isNotifying);
    if (mounted) {
      setState(() {
        isLoading = Future.value(true);
      });
    }
  }

  void addDevice(int index) async {
    String? deviceId = await goToPage(AddDevicePage(groupId: widget.groupId, index: index), 'AddDevicePage');
    if (deviceId != null) {
      // group.flowDeviceIds[index] = deviceId;
      if (mounted) {
        setState(() {
          isLoading = Future.value(null);
        });
      }
    }
    await setupService();
  }

  @override
  void initState() {
    setupService();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<MyGroup?>(
            future: _groupHandler.getGroup(widget.groupId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.title);
              } else {
                return const SizedBox.shrink();
              }
            }),
        actions: [
          IconButton(
              onPressed: () async {
                String? deviceId = await goToPage(GroupSettingsPage(groupId: widget.groupId), 'GroupSettingsPage');
                if (deviceId != null) {
                  // widget.groupId.flowDeviceIds.add(deviceId);
                  if (mounted) {
                    setState(() {
                      isLoading = Future.value(null);
                    });
                  }
                }
                await setupService();
              },
              icon: const Icon(Icons.settings))
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: FutureBuilder<bool?>(
        future: isLoading,
        initialData: null,
        builder: (context, snapshot) {
          if (!snapshot.hasData || group == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Row(
            children: [
              group!.energyDeviceIds[0].isEmpty
                  ? Expanded(
                      child: IconWithAction(
                        buttonTitle: 'Add Energy Meter',
                        icon: const Icon(Icons.electric_bolt_rounded),
                        onPressed: addEnergyDevice,
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                      child: SingleEnergyDevice(
                        deviceId: group!.energyDeviceIds[0],
                      ),
                    )),
              !snapshot.data!
                  ? Expanded(child: IconWithAction(buttonTitle: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(0)))
                  : group!.flowDeviceIds[0].isEmpty
                      ? Expanded(child: IconWithAction(buttonTitle: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(0)))
                      : Expanded(
                          child: Card(
                            color: Colors.grey[850],
                            elevation: 30,
                            child: SingleFloPro(
                              myGroup: group!,
                              streams: [
                                characteristics[group!.flowDeviceIds[0]]?[CharacteristicName.time]?.value,
                                characteristics[group!.flowDeviceIds[0]]?[CharacteristicName.pressure]?.value,
                                characteristics[group!.flowDeviceIds[0]]?[CharacteristicName.barometer]?.value,
                                characteristics[group!.flowDeviceIds[0]]?[CharacteristicName.flow]?.value,
                                characteristics[group!.flowDeviceIds[0]]?[CharacteristicName.temperature]?.value,
                                // timeCharacteristic?.value,
                                // pressureCharacteristic?.value,
                                // barometerCharacteristic?.value,
                                // flowCharacteristic?.value,
                                // temperatureCharacteristic?.value,
                              ],
                            ),
                          ),
                        ),
              !snapshot.data!
                  ? Expanded(child: IconWithAction(buttonTitle: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(1)))
                  : group!.flowDeviceIds[1].isEmpty
                      ? Expanded(child: IconWithAction(buttonTitle: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(1)))
                      : Expanded(
                          child: SingleFloPro(
                            myGroup: group!,
                            streams: [
                              characteristics[group!.flowDeviceIds[1]]?[CharacteristicName.time]?.value,
                              characteristics[group!.flowDeviceIds[1]]?[CharacteristicName.pressure]?.value,
                              characteristics[group!.flowDeviceIds[1]]?[CharacteristicName.barometer]?.value,
                              characteristics[group!.flowDeviceIds[1]]?[CharacteristicName.flow]?.value,
                              characteristics[group!.flowDeviceIds[1]]?[CharacteristicName.temperature]?.value,
                            ],
                            // streams: CombineLatestStream.list([
                            //   timeCharacteristic?.value,
                            //   pressureCharacteristic!.value,
                            //   barometerCharacteristic!.value,
                            //   flowCharacteristic!.value,
                            //   temperatureCharacteristic!.value,
                            // ]),
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }

  Future<void> setDeviceTime(String deviceId) async {
    try {
      DateTime timeNow = DateTime.now();
      var yearByte = Uint8List(2)..buffer.asInt16List()[0] = timeNow.year;
      List<int> timeNowBytes = [];
      timeNowBytes.addAll(yearByte);
      timeNowBytes.addAll([timeNow.month, timeNow.day, timeNow.hour, timeNow.minute, timeNow.second, 7, 0, 0]);

      await characteristics[deviceId]?[CharacteristicName.time]?.write(timeNowBytes);
      // await timeCharacteristic?.write(timeNowBytes);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  changeNotifying(bool notify, String deviceId) async {
    for (var char in characteristics[deviceId]!.entries) {
      await char.value?.setNotifyValue(notify);
    }
    // await timeCharacteristic?.setNotifyValue(notify);
    // await pressureCharacteristic?.setNotifyValue(notify);
    // await flowCharacteristic?.setNotifyValue(notify);
  }

  Future<dynamic> goToPage(Widget route, String settingsName) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => route, settings: RouteSettings(name: settingsName)));
  }

  void addEnergyDevice() async {
    final formKey = GlobalKey<FormState>();
    ValidateValues validateValues = ValidateValues();
    TuyaHandler tuyaHandler = TuyaHandler();
    String? password;
    String? ssid;
    String? initialSsid = await tuyaHandler.getWifiName();
    if (mounted) {
      showMyDialog(
        context,
        'Connect to Device',
        cancelText: 'Cancel',
        infoDialog: false,
        myOnPressed: () {
          formKey.currentState!.save();
          if (formKey.currentState!.validate()) {
            // print("widget.groupId, $ssid!, $password!");
            showMyDialog(
              context,
              'Connecting...',
              widgetContent: const MyCountDown(count: 100),
              infoDialog: false,
              onlyAction: true,
              barrierDismissible: false,
              confirmText: 'Cancel',
              myOnPressed: () {
                tuyaHandler.stopParing();
                Navigator.pop(context);
              },
            );
            tuyaHandler.startParing(widget.groupId, ssid!, password!, (deviceId) async {
              await _groupHandler.addEnergyDeviceToGroup(deviceId, widget.groupId, 0);
              await updateGroup();
              if (mounted) {
                Navigator.pop(context);
                showMyDialog(context, 'Success', message: "Successfully connected to device").then((value) {
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                });
              }
            }, (message) {
              if (mounted) {
                Navigator.pop(context);
                showMyDialog(context, 'Error', message: message);
              }
            });
          }
        },
        confirmText: 'Connect',
        widgetContent: SizedBox(
          width: 300,
          height: 160,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Text(
                  'Make sure your device is in paring mode.',
                  style: TextStyle(fontSize: 12, color: Colors.white60),
                ),
                const SizedBox(height: 10),
                MyTextFieldWidget(
                  labelText: 'Wifi name',
                  icon: const Icon(Icons.wifi),
                  initialValue: initialSsid,
                  setValue: (value) => ssid = value,
                  validate: (value) => validateValues.validateString(value),
                ),
                MyTextFieldWidget(
                  icon: const Icon(Icons.lock),
                  labelText: 'Wifi password',
                  setValue: (value) => password = value,
                  validate: (value) => validateValues.validateString(value),
                ),
                const SizedBox(height: 10),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //       onPressed: () {
                //         tuyaHandler.startParing(widget.groupId, ssid!, password!, (message) {}, (message) {});
                //       },
                //       child: const Text('Connect')),
                // ),
              ],
            ),
          ),
        ),
      );
    }
    // setState(() {
    //   group.energyDeviceIds[0] = 'Energy Meter';
    // });
    // addDevice(0);
  }
}
