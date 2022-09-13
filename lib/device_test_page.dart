// import 'package:flutter/material.dart';

// import 'logic/tuya_handler.dart';
// import 'widgets/my_alert_dialog.dart';

// class DeviceListPage extends StatefulWidget {
//   final int homeId;
//   const DeviceListPage({Key? key, required this.homeId}) : super(key: key);

//   @override
//   _DeviceListPageState createState() => _DeviceListPageState();
// }

// class _DeviceListPageState extends State<DeviceListPage> {
//   final TuyaHandler _tuyaHandler = TuyaHandler();
//   @override
//   Widget build(BuildContext context) {
//     print(widget.homeId);
//     return Scaffold(
//       appBar: AppBar(),
//       body: FutureBuilder<List<Map<String, dynamic>>?>(
//         future: _tuyaHandler.getDeviceListFromHomeId(widget.homeId),
//         builder: (context, deviceSnapshot) {
//           if (deviceSnapshot.hasData) {
//             List<Map<String, dynamic>> devices = deviceSnapshot.data!;
//             return Column(
//               children: [
//                 ListView.builder(
//                   itemCount: devices.length,
//                   shrinkWrap: true,
//                   itemBuilder: (context, deviceIndex) {
//                     return Card(
//                       child: ListTile(
//                         onTap: () {
//                           // _tuyaHandler.switchDevicePower(devices[index]['devId']);
//                           // _tuyaHandler.getDeviceProperties(devices[deviceIndex]['devId']);
//                           showMyDialog(context, '${widget.homeId} Devices',
//                               widgetContent: SizedBox(
//                                 height: 500,
//                                 width: 500,
//                                 child: FutureBuilder<List<Map<String, dynamic>>?>(
//                                   future: _tuyaHandler.getDeviceProperties(devices[deviceIndex]['devId']),
//                                   builder: (context, propSnapshot) {
//                                     if (propSnapshot.hasData) {
//                                       List<Map<String, dynamic>> properties = propSnapshot.data!;
//                                       return StreamBuilder<Map<String, dynamic>>(
//                                           stream: _tuyaHandler.deviceValueStream(),
//                                           builder: (context, dValueSnapshot) {
//                                             print("____STREAM____");
//                                             print("____${dValueSnapshot.data.toString()} ____");
//                                             print("_____________");
//                                             // print(properties.map((e) => "${dValueSnapshot.data?[e["dpId"]]}"));
//                                             return Column(
//                                               children: [
//                                                 SizedBox(
//                                                     height: 100,
//                                                     child: SingleChildScrollView(
//                                                         child: Row(
//                                                       children: properties
//                                                           .map((e) => Card(
//                                                                   child: Padding(
//                                                                 padding: const EdgeInsets.all(8.0),
//                                                                 child: Text("${dValueSnapshot.data?[e["dpId"]]}"),
//                                                               )))
//                                                           .toList(),
//                                                     ))),
//                                                 SizedBox(
//                                                   height: 400,
//                                                   width: 500,
//                                                   child: ListView.builder(
//                                                     itemCount: properties.length,
//                                                     shrinkWrap: true,
//                                                     itemBuilder: (context, propindex) {
//                                                       return Card(
//                                                         child: ListTile(
//                                                           onTap: () {
//                                                             // print(properties[index]['dpId']);
//                                                             _tuyaHandler.setDeviceValue(devices[deviceIndex]['devId'], properties[propindex]['dpId']);
//                                                             // _tuyaHandler.getDeviceProperties(devices[deviceIndex]['devId']);
//                                                           },
//                                                           title: Text('${properties[propindex]['code']}'),
//                                                           trailing: SizedBox(
//                                                             width: 150,
//                                                             child: Row(
//                                                               children: [
//                                                                 ElevatedButton(
//                                                                   onPressed: () {
//                                                                     _tuyaHandler.readDeviceValues(
//                                                                         devices[deviceIndex]['devId'], properties[propindex]['dpId']);
//                                                                   },
//                                                                   child: const Text('data'),
//                                                                 ),
//                                                                 ElevatedButton(
//                                                                   onPressed: () {
//                                                                     print(properties[propindex]);
//                                                                   },
//                                                                   child: const Text('prop'),
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           subtitle: Text('${properties[propindex]['dpId']} '),
//                                                         ),
//                                                         // subtitle: Text('${properties[propindex]['property']}'),
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           });
//                                     } else {
//                                       return const Center(child: CircularProgressIndicator());
//                                     }
//                                   },
//                                 ),
//                               ));
//                         },
//                         title: Text('${devices[deviceIndex]['name']}'),
//                         subtitle: Text('${devices[deviceIndex]['devId']}'),
//                       ),
//                     );
//                   },
//                 ),
//                 ElevatedButton(
//                     onPressed: () {
//                       // showMyLoadingDialog(context);
//                       _tuyaHandler.startParing(widget.homeId, '', 'JJ20120902', (result) {
//                         if (mounted) {
//                           // Navigator.pop(context);
//                           showMyDialog(context, 'Success', message: 'result: $result');
//                         }
//                       }, (message) {
//                         if (mounted) {
//                           // Navigator.pop(context);
//                           showMyDialog(context, 'Error', message: message);
//                         }
//                       });
//                     },
//                     child: const Text('Start Paring')),
//                 ElevatedButton(
//                     onPressed: () {
//                       // showMyLoadingDialog(context);
//                       _tuyaHandler.stopParing();
//                     },
//                     child: const Text('Stop Paring')),
//               ],
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
