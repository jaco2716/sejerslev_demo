import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sejerslev_demo/logic/tuya_handler.dart';
import 'package:sejerslev_demo/widgets/icon_with_ation.dart';

import 'my_gauge.dart';
import 'my_single_chart.dart';

class SingleEnergyDevice extends StatefulWidget {
  final String deviceId;
  const SingleEnergyDevice({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<SingleEnergyDevice> createState() => _SingleEnergyDeviceState();
}

class _SingleEnergyDeviceState extends State<SingleEnergyDevice> {
  final TuyaHandler _tuyaHandler = TuyaHandler();
  late Timer _timer;
  StreamSubscription<Map<String, dynamic>>? deviceValueStream;

  bool isOnline = false;
  bool isOn = false;
  double curCurrent = 0;
  double curPower = 0;
  double curVoltage = 0;
  double totalEle = 0;

  ///
  ///switch_1 - dpId: 1 - unit: bool
  ///countdown_1 - dpId: 9 - unit: s
  ///cur_current - dpId: 18 - unit: mA
  ///cur_power - dpId: 19 - unit: W
  ///cur_voltage - dpId: 20 - unit: V
  ///total_ele - dpId: 101 - unit: KWh
  ///
  ///

  void startUpdateTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (value) {
      setState(() {});
    });
  }

  void setStreamValue() {
    deviceValueStream = _tuyaHandler.deviceValueStream()?.listen((event) {
      print(event);
      isOnline = event["isOnline"] as bool? ?? false;
      isOn = event["1"] as bool? ?? false;
      curCurrent = (event["18"] as int? ?? 0).toDouble() / 1000; // Ampere
      curPower = (event["19"] as int? ?? 0).toDouble();
      curVoltage = (event["20"] as int? ?? 0).toDouble() / 10;
      totalEle = (event["101"] as int? ?? 0).toDouble() / 100; // kWH
      setState(() {});
    });
  }

  void getProps() async {
    var props = await _tuyaHandler.getDeviceProperties(widget.deviceId);
    if (props != null) {
      for (var prop in props) {
        print('------------');
        print(prop);
        print('------------');
      }
    }
  }

  @override
  void initState() {
    getProps();
    print('device ID');
    print(widget.deviceId);
    setStreamValue();
    startUpdateTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    deviceValueStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isOnline) {
      return const IconWithAction(
        icon: Icon(Icons.wifi_off_rounded),
        title: 'Device is Offline',
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // child: StreamBuilder<Map<String, dynamic>>(
      //     stream: _tuyaHandler.deviceValueStream(),
      //     builder: (context, dValueSnapshot) {
      child: Column(
        children: [
          // SizedBox(
          //     height: 100,
          //     child: SingleChildScrollView(
          //         child: Row(
          //       children: properties
          //           .map((e) => Card(
          //                   child: Padding(
          //                 padding: const EdgeInsets.all(8.0),
          //                 child: Text("${dValueSnapshot.data?[e["dpId"]]}"),
          //               )))
          //           .toList(),
          //     ))),
          Card(
            color: isOn ? Colors.blue : Colors.grey,
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(20),
            // ),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                _tuyaHandler.setDeviceValue(widget.deviceId, "1");
              },
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
          Text(isOn ? 'Power on' : 'Power off'),
          DetailGaugeDial(
            value: curCurrent,
            isPressure: false,
            title: 'Electric Current',
            messureUnit: 'A',
            // start2: 20,
            end: 100,
          ),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Electric Current - Ampere', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          // MySingleChart(value: (dValueSnapshot.data?["20"] as int? ?? 0).toDouble()),
          MySingleChart(value: curCurrent),
          // const SizedBox(height: 20),
          // const Divider(height: 1),
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text('Electricity - V - curVoltage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          // ),
          // MySingleChart(value: curVoltage),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Total Electricity - KWh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          // MySingleChart(value: (dValueSnapshot.data?["20"] as int? ?? 0).toDouble()),
          MySingleChart(value: totalEle / 100),
          // const Divider(height: 1),
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: Text('Total Electricity - W - curPower', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          // ),
          // // MySingleChart(value: (dValueSnapshot.data?["20"] as int? ?? 0).toDouble()),
          // MySingleChart(value: curPower),
        ],
      ),
    );
  }
}
