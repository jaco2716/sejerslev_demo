import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../model/my_group.dart';
import '../pages/group_settings_page.dart';
import 'icon_with_ation.dart';
import 'my_gauge.dart';
import 'my_single_chart.dart';

class SingleFloPro extends StatefulWidget {
  final MyGroup myGroup;
  final List<Stream<List<int>>?> streams;
  // final CombineLatestStream<dynamic, List<List<int>>> streams;
  const SingleFloPro({Key? key, required this.streams, required this.myGroup}) : super(key: key);

  @override
  _SingleFloProState createState() => _SingleFloProState();
}

class _SingleFloProState extends State<SingleFloPro> {
  @override
  Widget build(BuildContext context) {
    if (widget.streams.any((element) => element == null)) {
      return IconWithAction(
        buttonTitle: 'Settings',
        icon: const Icon(Icons.warning_amber_rounded),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupSettingsPage(groupId: widget.myGroup.id)));
        },
        title: 'Could not get data from device.\nTry disconnecting and connecting again.',
      );
    }
    List<Stream<List<int>>> streams = widget.streams.map((element) => element!).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<List<int>>>(
            // stream: pressureCharacteristic?.value,
            stream: CombineLatestStream.list(streams),
            // stream: widget.streams,
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
                    const Divider(height: 1),

                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Flow - CFH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    MySingleChart(value: flowValue),
                    // MySingleChart(value: 1000),

                    const Divider(height: 1),

                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Pressure - inH2O', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  double celsiusToFahrenheit(double celsuis) {
    return (celsuis * 9 / 5) + 32;
  }
}
