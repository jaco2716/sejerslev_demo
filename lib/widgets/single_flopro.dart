import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../model/my_group.dart';
import 'icon_with_ation.dart';
import 'my_gauge.dart';
import 'my_single_chart.dart';

class SingleFloPro extends StatefulWidget {
  final MyGroup myGroup;
  final String title;
  final void Function() onConnectPressed;
  final List<Stream<List<int>>?> streams;
  // final CombineLatestStream<dynamic, List<List<int>>> streams;
  const SingleFloPro({
    Key? key,
    required this.streams,
    required this.myGroup,
    required this.onConnectPressed,
    required this.title,
  }) : super(key: key);

  @override
  _SingleFloProState createState() => _SingleFloProState();
}

class _SingleFloProState extends State<SingleFloPro> {
  // Stream<List<List<int>>>? fakeStream;

  // fakeStreamInit() {
  //   fakeStream = Stream.periodic(
  //     const Duration(seconds: 3),
  //     (computationCount) {
  //       return [
  //         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  //         [0, 0, 0, 0],
  //         [0, 0, 0, 0],
  //         [0, 0, 0, 0],
  //         [0, 0],
  //       ];
  //     },
  //   );
  // }

  // @override
  // void initState() {
  //   fakeStreamInit();
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.streams.any((element) => element == null)) {
      return IconWithAction(
        buttonTitle: 'Connect Device',
        icon: const Icon(Icons.wifi_off_rounded),
        onPressed: widget.onConnectPressed,
        // {
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => GroupSettingsPage(groupId: widget.myGroup.id)));
        // },
        title: 'Could not connect to device.',
      );
    }
    List<Stream<List<int>>> streams = widget.streams.map((element) => element!).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<List<int>>>(
            stream: CombineLatestStream.list(streams),
            // stream: fakeStream,
            builder: (context, streamSnapshot) {
              if (streamSnapshot.hasData) {
                if (streamSnapshot.data?[0].length != 10 ||
                    streamSnapshot.data?[1].length != 4 ||
                    streamSnapshot.data?[2].length != 4 ||
                    streamSnapshot.data?[3].length != 4 ||
                    streamSnapshot.data?[4].length != 2) {
                  return const SizedBox(height: 700, width: 150, child: Center(child: CircularProgressIndicator()));
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
                // Pressure  - inH2O
                // var pressureValue = (pressureData - barometerData).toDouble() * 0.00040146303904694;
                var pressureValue = (pressureData - barometerData).toDouble() / 1000000;
                var temperatureBytes = Uint8List.fromList(streamSnapshot.data![4]);
                var temperatureValue = ByteData.view(temperatureBytes.buffer).getInt16(0, Endian.little) / 100;
                var flowBytes = Uint8List.fromList(streamSnapshot.data![3]);
                var flowData = ByteData.view(flowBytes.buffer).getInt32(0, Endian.little);
                //Flow - CFH
                // var flowValue = flowData / 100;
                var flowValue = flowData / 100 * 0.4719474432;
                // var flowValue = ((flowData * (1545 / 28.964) * ((((temperatureValue / 100) * 9 / 5) + 32) + 460)) /
                //         (144 * (pressureData * 0.00002952998015649))) /
                //     60;

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
                          Container(
                              padding: const EdgeInsets.all(10),
                              // height: 30,

                              child: Text(
                                widget.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Column(
                            children: [
                              Text(
                                widget.myGroup.temperatureUnit == TemperatureUnit.celsius
                                    ? '${(temperatureValue).toStringAsFixed(2)}°'
                                    : '${celsiusToFahrenheit(temperatureValue).toStringAsFixed(2)}°',
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
                          // value: flowValue,
                          value: widget.myGroup.temperatureUnit == TemperatureUnit.celsius ? flowValue : lPerMinToCFH(flowValue),
                          isPressure: false,
                          title: 'Flow',
                          messureUnit: widget.myGroup.temperatureUnit == TemperatureUnit.celsius ? 'L/min' : 'CFH',
                        ),
                        DetailGaugeDial(
                          // value: pressureValue,
                          value: widget.myGroup.temperatureUnit == TemperatureUnit.celsius ? pressureValue : barToPsi(pressureValue),
                          isPressure: true,
                          title: 'Pressure',
                          messureUnit: widget.myGroup.temperatureUnit == TemperatureUnit.celsius ? 'Bar' : 'PSI',
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Flow - L/min', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    MySingleChart(value: flowValue),
                    // MySingleChart(value: 0),
                    const Divider(height: 1),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Pressure - Bar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    MySingleChart(value: pressureValue),
                  ],
                );
              } else if (streamSnapshot.hasError) {
                // TODO: do something with the error
                return SizedBox(height: 700, width: 250, child: Text(streamSnapshot.error.toString()));
              }
              // TODO: the data is not ready, show a loading indicator
              return const SizedBox(height: 700, width: 250, child: Center(child: CircularProgressIndicator()));
            }),
      ),
    );
  }

  double celsiusToFahrenheit(double value) {
    return (value * 9 / 5) + 32;
  }

  double barToPsi(double value) {
    return value * 14.503773773;
  }

  double lPerMinToCFH(double value) {
    return value * 2.1188800032893;
  }
}
