import 'dart:math';
import 'dart:typed_data';
import 'package:sejerslev_demo/model/my_group.dart';
import 'package:sejerslev_demo/pages/add_device_page.dart';
import 'package:sejerslev_demo/pages/group_list_page.dart';
import 'package:sejerslev_demo/pages/group_settings_page.dart';
import 'package:sejerslev_demo/widgets/my_single_chart.dart';

import '/widgets/my_chart.dart';
import '/widgets/my_scrollview_w_constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '/model/providers/select_type_provider.dart';
import '/widgets/my_dropdown_button.dart';
import 'create_group_page.dart';

class SingleGroupPage extends StatefulWidget {
  // final List<BluetoothService> services;
  final MyGroup myGroup;

  // final String title;
  const SingleGroupPage({
    Key? key,
    required this.myGroup,
    // required this.title,
    // required this.services,
  }) : super(key: key);

  @override
  State<SingleGroupPage> createState() => _SingleGroupPageState();
}

class _SingleGroupPageState extends State<SingleGroupPage> {
  // bool isOn = true;
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  Future<bool?> isLoading = Future.value(null);
  BluetoothService? dataService;
  BluetoothService? timeService;
  BluetoothCharacteristic? pressureCharacteristic;
  BluetoothCharacteristic? barometerCharacteristic;
  BluetoothCharacteristic? flowCharacteristic;
  BluetoothCharacteristic? temperatureCharacteristic;
  BluetoothCharacteristic? timeCharacteristic;
  List<List<int>> dateData = [];
  bool isNotifying = true;
  List<BluetoothDevice> devices = [];

  Future<List<List<BluetoothService>>> getBTDeviceServices() async {
    List<List<BluetoothService>> devicesServies = [];
    devices = await _flutterBlue.connectedDevices;
    for (var device in devices) {
      if (widget.myGroup.flowDeviceIds.contains(device.id.id)) {
        var tempService = await device.discoverServices();
        devicesServies.add(tempService);
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
    //Time setup
    int timeServiceIndex = devicesServies[0].indexWhere((element) => element.uuid.toString() == '00001805-0000-1000-8000-00805f9b34fb');
    if (timeServiceIndex != -1) timeService = devicesServies[0][timeServiceIndex];
    int timeIndex = timeService?.characteristics.indexWhere((element) => element.uuid.toString() == '00002a2b-0000-1000-8000-00805f9b34fb') ?? -1;
    if (timeIndex != -1) timeCharacteristic = timeService?.characteristics[timeIndex];

    //Service setup
    int serviceIndex = devicesServies[0].indexWhere((element) => element.uuid.toString() == '8d8cceb9-ec48-4621-b293-0bafb0e0fa2d');
    if (serviceIndex != -1) dataService = devicesServies[0][serviceIndex];
    int pressureIndex = dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '3300c0b5-2369-4322-8296-5564f44850b3') ?? -1;
    if (pressureIndex != -1) pressureCharacteristic = dataService?.characteristics[pressureIndex];
    int barometerIndex =
        dataService?.characteristics.indexWhere((element) => element.uuid.toString() == 'c6ae9dac-5cfe-43cc-9c24-cbcf6e48e820') ?? -1;
    if (barometerIndex != -1) barometerCharacteristic = dataService?.characteristics[barometerIndex];
    // int flowIndex = dataService.characteristics.indexWhere((element) => element.uuid.toString() == '951770bd-a550-4466-b16f-4bc3170f4d0e');
    int flowIndex = dataService?.characteristics.indexWhere((element) => element.uuid.toString() == '7cb8e55f-d785-4c62-b6f7-ba6ba7581b7b') ?? -1;
    if (flowIndex != -1) flowCharacteristic = dataService?.characteristics[flowIndex];
    int temperatureIndex =
        dataService?.characteristics.indexWhere((element) => element.uuid.toString() == 'f3d4b10d-7485-4945-a849-162d8acc1f42') ?? -1;
    if (temperatureIndex != -1) temperatureCharacteristic = dataService?.characteristics[temperatureIndex];

    var timeValue = await timeCharacteristic?.read();
    if (timeValue != null) {
      var bytes = Uint8List.fromList(timeValue);
      var yearValue = ByteData.view(bytes.buffer).getInt16(0, Endian.little);
      DateTime deviceDate = DateTime(yearValue, bytes[2], bytes[3], bytes[4], bytes[5], bytes[6]);
      var dateNow = DateTime.now();
      if (dateNow.difference(deviceDate).inMinutes > 2) {
        await setDeviceTime();
      }
    }
    await timeCharacteristic?.setNotifyValue(isNotifying);
    await pressureCharacteristic?.setNotifyValue(isNotifying);
    await barometerCharacteristic?.setNotifyValue(isNotifying);
    await flowCharacteristic?.setNotifyValue(isNotifying);
    await temperatureCharacteristic?.setNotifyValue(isNotifying);
    if (mounted) {
      setState(() {
        isLoading = Future.value(true);
      });
    }
  }

  void addDevice(int index) async {
    String? deviceId = await goToPage(AddDevicePage(myGroup: widget.myGroup, index: index), 'AddDevicePage');
    if (deviceId != null) {
      widget.myGroup.flowDeviceIds[index] = deviceId;
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
        title: Text(widget.myGroup.title),
        actions: [
          IconButton(
              onPressed: () async {
                String? deviceId = await goToPage(GroupSettingsPage(myGroup: widget.myGroup), 'GroupSettingsPage');
                if (deviceId != null) {
                  widget.myGroup.flowDeviceIds.add(deviceId);
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // } else if (!snapshot.data!) {
          //   return Row(
          //     children: [
          //       Expanded(
          //           child: NoDeviceAdded(
          //               title: 'Add Energy Meter',
          //               icon: const Icon(Icons.electric_bolt_rounded),
          //               onPressed: () {
          //                 setState(() {
          //                   widget.myGroup.energyDeviceIds[0] = 'Energy Meter';
          //                 });
          //                 // addDevice(0);
          //               })),
          //       Expanded(
          //         child: Card(
          //             elevation: 30,
          //             color: Colors.grey[850],
          //             child: NoDeviceAdded(title: 'Add Flow Meter', icon: const Icon(Icons.gas_meter_rounded), onPressed: () => addDevice(1))),
          //       ),
          //       Expanded(child: NoDeviceAdded(title: 'Add Flow Meter', icon: const Icon(Icons.gas_meter_rounded), onPressed: () => addDevice(2))),
          //       // Column(
          //       //   children: [
          //       //     const SizedBox(width: double.infinity, height: 40),
          //       //     const Icon(
          //       //       Icons.devices,
          //       //       size: 140,
          //       //       color: Colors.grey,
          //       //     ),
          //       //     const Padding(
          //       //       padding: EdgeInsets.all(8.0),
          //       //       child: Text(
          //       //         'No devices',
          //       //         // style: TextStyle(color: Colors.grey),
          //       //       ),
          //       //     ),
          //       //     Padding(
          //       //       padding: const EdgeInsets.all(16.0),
          //       //       child: ElevatedButton(
          //       //           onPressed: () async {
          //       //             String? deviceId = await goToPage(AddDevicePage(myGroup: widget.myGroup), 'AddDevicePage');
          //       //             if (deviceId != null) {
          //       //               widget.myGroup.deviceIds.add(deviceId);
          //       //               if (mounted) {
          //       //                 setState(() {
          //       //                   isLoading = Future.value(null);
          //       //                 });
          //       //               }
          //       //             }
          //       //             await setupService();
          //       //           },
          //       //           child: const Text('Add Device')),
          //       //     ),
          //       //   ],
          //       // ),
          //     ],
          //   );
          // }
          return Row(
            children: [
              widget.myGroup.energyDeviceIds[0].isEmpty
                  ? Expanded(
                      child: NoDeviceAdded(
                          title: 'Add Energy Meter',
                          icon: const Icon(Icons.electric_bolt_rounded),
                          onPressed: () {
                            setState(() {
                              widget.myGroup.energyDeviceIds[0] = 'Energy Meter';
                            });
                            // addDevice(0);
                          }))
                  : Expanded(
                      child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<List<double>>(
                            stream: null,
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  Card(
                                    color: Colors.blue,
                                    // decoration: BoxDecoration(
                                    //   borderRadius: BorderRadius.circular(20),
                                    // ),
                                    clipBehavior: Clip.hardEdge,
                                    child: InkWell(
                                      onTap: () {},
                                      // borderRadius: BorderRadius.circular(20),
                                      child: const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Icon(
                                          Icons.power_settings_new_rounded,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Text('Power on'),
                                  const DetailGaugeDial(
                                    value: 0,
                                    isPressure: false,
                                    title: 'Electicity',
                                    messureUnit: 'KHW',
                                    start2: 20,
                                    end: 500,
                                  ),
                                  // const SizedBox(height: 20),
                                  const Divider(height: 1),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Electicity - KWH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  const MySingleChart(value: 0),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Total Electicity - KWH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                                  const MySingleChart(value: 0.01),
                                ],
                              );
                            }),
                      ),
                    )),
              !snapshot.data!
                  ? Expanded(child: NoDeviceAdded(title: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(0)))
                  : widget.myGroup.flowDeviceIds[0].isEmpty
                      ? Expanded(child: NoDeviceAdded(title: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(0)))
                      : Expanded(
                          child: Card(
                            color: Colors.grey[850],
                            elevation: 30,
                            child: SingleFloPro(
                              myGroup: widget.myGroup,
                              streams: CombineLatestStream.list([
                                timeCharacteristic!.value,
                                pressureCharacteristic!.value,
                                barometerCharacteristic!.value,
                                flowCharacteristic!.value,
                                temperatureCharacteristic!.value,
                              ]),
                            ),
                          ),
                        ),
              !snapshot.data!
                  ? Expanded(child: NoDeviceAdded(title: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(1)))
                  : widget.myGroup.flowDeviceIds[1].isEmpty
                      ? Expanded(child: NoDeviceAdded(title: 'Add Flow Meter', icon: const Icon(Icons.air), onPressed: () => addDevice(1)))
                      : Expanded(
                          child: SingleFloPro(
                            myGroup: widget.myGroup,
                            streams: CombineLatestStream.list([
                              timeCharacteristic!.value,
                              pressureCharacteristic!.value,
                              barometerCharacteristic!.value,
                              flowCharacteristic!.value,
                              temperatureCharacteristic!.value,
                            ]),
                          ),
                        ),
            ],
          );
        },
      ),
    );
  }

  Future<void> setDeviceTime() async {
    try {
      DateTime timeNow = DateTime.now();
      var yearByte = Uint8List(2)..buffer.asInt16List()[0] = timeNow.year;
      List<int> timeNowBytes = [];
      timeNowBytes.addAll(yearByte);
      timeNowBytes.addAll([timeNow.month, timeNow.day, timeNow.hour, timeNow.minute, timeNow.second, 7, 0, 0]);
      await timeCharacteristic?.write(timeNowBytes);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  changeNotifying(bool notify) async {
    await timeCharacteristic?.setNotifyValue(notify);
    await pressureCharacteristic?.setNotifyValue(notify);
    await flowCharacteristic?.setNotifyValue(notify);
  }

  Future<dynamic> goToPage(Widget route, String settingsName) async {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => route, settings: RouteSettings(name: settingsName)));
  }
}

class SingleFloPro extends StatefulWidget {
  final MyGroup myGroup;
  final CombineLatestStream<dynamic, List<List<int>>> streams;
  const SingleFloPro({Key? key, required this.streams, required this.myGroup}) : super(key: key);

  @override
  _SingleFloProState createState() => _SingleFloProState();
}

class _SingleFloProState extends State<SingleFloPro> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<List<int>>>(
            // stream: pressureCharacteristic?.value,
            stream: widget.streams,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
                if (streamSnapshot.data?[0].length != 10 ||
                    streamSnapshot.data?[1].length != 4 ||
                    streamSnapshot.data?[2].length != 4 ||
                    streamSnapshot.data?[3].length != 4 ||
                    streamSnapshot.data?[4].length != 2) {
                  return const SizedBox(height: 150, width: 150, child: Center(child: CircularProgressIndicator()));
                  // return const SizedBox(height: 250, width: 250, child: Center(child: Text('No data')));
                }
                var timeBytes = Uint8List.fromList(streamSnapshot.data![0]);
                var yearValue = ByteData.view(timeBytes.buffer).getInt16(0, Endian.little);
                DateTime date = DateTime(yearValue, timeBytes[2], timeBytes[3], timeBytes[4], timeBytes[5], timeBytes[6]);
                var dfTime = DateFormat('HH:mm');
                var dfDate = DateFormat('dd/MM/yyyy');

                var barometerBytes = Uint8List.fromList(streamSnapshot.data![2]);
                var barometerData = ByteData.view(barometerBytes.buffer).getInt32(0, Endian.little);
                // var barometerValue = ByteData.view(barometerBytes.buffer).getInt32(0, Endian.little) * 0.00002952998015649;
                var pressureBytes = Uint8List.fromList(streamSnapshot.data![1]);
                var pressureData = ByteData.view(pressureBytes.buffer).getInt32(0, Endian.little);
                var pressureValue = (pressureData - barometerData).toDouble() * 0.00040146303904694;
                var temperatureBytes = Uint8List.fromList(streamSnapshot.data![4]);
                var temperatureValue = ByteData.view(temperatureBytes.buffer).getInt16(0, Endian.little);
                var flowBytes = Uint8List.fromList(streamSnapshot.data![3]);
                var flowData = ByteData.view(flowBytes.buffer).getInt32(0, Endian.little);
                // var flowValue = ((flowData * (1545 / 28.964) * ((((temperatureValue / 100) * 9 / 5) + 32) + 460)) /
                //         (144 * (pressureData * 0.00002952998015649))) /
                //     60;
                var flowValue = flowData / 100;

                // print('//bytes');
                // print(pressureBytes);
                // print(barometerBytes);
                // print(flowBytes);
                // print(numberValue);
                //1012376
                //1084960
                //TODO udregning
                // numbervalue - BarometerValue * in/H20
                //TODO !!! Flow bliver udreget ved hjælp af temperatur og pressure??
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                dfTime.format(date),
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                dfDate.format(date),
                                style: const TextStyle(fontSize: 11, color: Colors.white60),
                              ),
                            ],
                          ),
                          // const Padding(
                          //   padding: EdgeInsets.all(8.0),
                          //   child: Icon(Icons.menu, color: Colors.grey),
                          // ),
                          Column(
                            children: [
                              Text(
                                widget.myGroup.temperatureUnit == TemperatureUnit.celsius
                                    ? '${(temperatureValue / 100).toStringAsFixed(2)}°'
                                    : '${celsiusToFahrenheit(temperatureValue / 100).toStringAsFixed(2)}°',
                                // '${(((temperatureValue / 100) * 9 / 5) + 32).toStringAsFixed(2)}°',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.myGroup.temperatureUnit.name[0].toUpperCase()}${widget.myGroup.temperatureUnit.name.substring(1)}',
                                style: const TextStyle(fontSize: 11, color: Colors.white60),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    // MyDropdownButton(selectTypeListProvider: selectTypeListProvider),
                    // MyDropdownButton(selectTypeListProvider: context.read<SelectTypeListProvider>()),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DetailGaugeDial(
                          value: flowValue,
                          isPressure: false,
                          title: 'Flow',
                          messureUnit: 'CFH',
                        ),
                        DetailGaugeDial(
                          value: pressureValue,
                          // value: (((pressureValue - barometerValue).toDouble() * 0.00040146303904694)),
                          isPressure: true,
                          title: 'Pressure',
                          messureUnit: 'inH2O',
                        ),
                      ],
                    ),
                    // Consumer<SelectTypeListProvider>(
                    //   builder: (context, value, child) {
                    //     if (value.indexSelected == 0) {
                    //       return DetailGaugeDial(
                    //         value: flowValue,
                    //         isPressure: false,
                    //         title: 'Flow',
                    //         messureUnit: 'CFH',
                    //       );
                    //     } else {
                    //       return Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           DetailGaugeDial(
                    //             value: pressureValue,
                    //             // value: (((pressureValue - barometerValue).toDouble() * 0.00040146303904694)),
                    //             isPressure: true,
                    //             title: 'Pressure',
                    //             messureUnit: 'inH2O',
                    //           ),
                    //           const SizedBox(width: 20),
                    //           DetailGaugeDial(
                    //             value: barometerValue,
                    //             isPressure: true,
                    //             title: 'Barometer',
                    //             messureUnit: 'inHg',
                    //             start2: 25,
                    //             start3: 35,
                    //             end: 60,
                    //           ),
                    //         ],
                    //       );
                    //     }
                    //   },
                    // ),
                    const Divider(height: 1),

                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Flow - CFH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    MySingleChart(value: flowValue),

                    const Divider(height: 1),

                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Pressure - inH2O', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    MySingleChart(value: pressureValue),

                    // MySingleChart(value: pressureValue),
                    // MyChart(flowValue: flowValue, pressureValue: pressureValue),
                    // MyChart(flowValue: flowValue, pressureValue: pressureValue),
                  ],
                );
              } else if (streamSnapshot.hasError) {
                // TODO: do something with the error
                return SizedBox(height: 250, width: 250, child: Text(streamSnapshot.error.toString()));
              }
              // TODO: the data is not ready, show a loading indicator
              return const SizedBox(height: 250, width: 250, child: Center(child: CircularProgressIndicator()));
            }),
      ),
    );
  }
}

class NoDeviceAdded extends StatelessWidget {
  final String title;
  final Icon icon;

  final void Function() onPressed;
  const NoDeviceAdded({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // if (isEnergyMeter) {
    //   icon = Icons.electric_bolt_rounded;
    //   title = 'Add Energy Meter';
    // } else {
    //   icon = Icons.gas_meter;
    //   title = 'Add Flow Meter';
    // }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon.icon,
          size: 120,
          color: Colors.grey,
        ),
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Text(
        //     title,
        //     // style: TextStyle(color: Colors.grey),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton(onPressed: onPressed, child: Text(title)),
        ),
        const SizedBox(height: kToolbarHeight),
      ],
    );
  }
}

class DetailGaugeDial extends StatelessWidget {
  final double value;
  final bool isPressure;
  final String title;
  final String messureUnit;
  final double start, start1, start2, start3, end;
  const DetailGaugeDial({
    Key? key,
    required this.value,
    required this.isPressure,
    required this.title,
    required this.messureUnit,
    this.start = 0,
    this.start1 = 0,
    this.start2 = 40,
    this.start3 = 60,
    this.end = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color1, color2, color3;
    double minAngle = -140;
    double maxAngle = 140;
    if (isPressure) {
      color1 = Colors.white;
      color2 = Colors.green;
      color3 = Colors.blue;
    } else {
      color1 = Colors.green;
      color2 = Colors.orange;
      color3 = Colors.red;
    }
    return SizedBox(
      height: 165,
      width: 125,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              GaugeAnootation(
                // valueRange: end - start1,
                valueStart: start1,
                valueEnd: end,
                interval: (end - start1) / 10,
              ),
              TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(begin: 0.0, end: value),
                  builder: (context, double tweenValue, child) {
                    return RadialGauge(
                      axes: [
                        RadialGaugeAxis(
                          minValue: start1,
                          maxValue: end,
                          minAngle: minAngle,
                          maxAngle: maxAngle,
                          radius: 0.9,
                          width: 0.17,
                          color: Colors.transparent,
                          pointers: [
                            RadialNeedlePointer(
                                value: tweenValue,
                                thicknessStart: 16,
                                thicknessEnd: 0,
                                length: 0.85,
                                knobRadiusAbsolute: 8,
                                color: Colors.white,
                                knobColor: Colors.white)
                          ],
                          ticks: [
                            RadialTicks(
                                interval: (end - start1) / 10,
                                alignment: RadialTickAxisAlignment.inside,
                                color: Colors.white,
                                length: 0.22,
                                children: [
                                  RadialTicks(
                                    // interval: 50,
                                    ticksInBetween: 5,
                                    length: 0.2,
                                    color: Colors.grey,
                                  ),
                                ]),
                          ],
                          segments: [
                            RadialGaugeSegment(
                              minValue: start1,
                              maxValue: start2,
                              minAngle: minAngle + 30,
                              maxAngle: -50,
                              color: color1,
                            ),
                            RadialGaugeSegment(
                              minValue: start2,
                              maxValue: start3,
                              minAngle: -50,
                              maxAngle: 50,
                              color: color2,
                            ),
                            RadialGaugeSegment(
                              minValue: start3,
                              maxValue: end,
                              minAngle: 50,
                              maxAngle: maxAngle,
                              color: color3,
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      messureUnit,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                        width: 60,
                        height: 22,
                        child: FittedBox(
                          child: Text(
                            value.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // child: Text('820.88', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    // Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );

    // return SfRadialGauge(
    //   axes: <RadialAxis>[
    //     RadialAxis(
    //       minimum: 0,
    //       maximum: 100,
    //       // showLabels: false,
    //       ranges: <GaugeRange>[
    //         GaugeRange(startValue: start1, endValue: start2, color: color1),
    //         GaugeRange(startValue: start2, endValue: start3, color: color2),
    //         GaugeRange(startValue: start3, endValue: end, color: color3)
    //       ],
    //       pointers: <GaugePointer>[
    //         NeedlePointer(
    //           // knobStyle: const KnobStyle(knobRadius: 0.1, borderWidth: 20),
    //           // tailStyle: const TailStyle(width: 2, length: 0.2),
    //           // needleLength: 0.9,
    //           // needleStartWidth: 2,
    //           // needleEndWidth: 3,
    //           animationDuration: 1000,
    //           animationType: AnimationType.ease,
    //           enableAnimation: true,
    //           value: value,
    //         )
    //       ],
    //       annotations: <GaugeAnnotation>[
    //         GaugeAnnotation(
    //           widget: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Text('${value.round()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
    //               Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
    //             ],
    //           ),
    //           angle: 90,
    //           positionFactor: 0.6,
    //         )
    //       ],
    //     )
    //   ],
    // );
  }
}

class GaugeAnootation extends StatelessWidget {
  // final double valueRange;
  final double valueStart;
  final double valueEnd;
  final double interval;
  const GaugeAnootation({
    Key? key,
    // required this.valueRange,
    this.interval = 10,
    required this.valueStart,
    required this.valueEnd,
  }) : super(key: key);

  final double radius = 45.0;

  List<Widget> list() {
    List<int> data = [];
    double currentAngle = 2.3;
    double angleDiff = 0.483;
    for (var i = valueStart; i < valueEnd + 1; i += interval) {
      data.add(i.toInt());
    }
    return data.map((int value) {
      final x = cos(currentAngle) * radius;
      final y = sin(currentAngle) * radius;
      currentAngle += angleDiff;
      return _radialListItem(x, y, value);
    }).toList();
  }

  Widget _radialListItem(double x, double y, int value) {
    return Center(
      child: Transform(
          transform: Matrix4.translationValues(x, y, 0.0),
          child: Text(
            '$value',
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: list(),
    );
  }
}

double celsiusToFahrenheit(double celsuis) {
  return (celsuis * 9 / 5) + 32;
}
