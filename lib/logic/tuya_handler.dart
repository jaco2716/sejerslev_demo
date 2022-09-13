import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

class TuyaHandler extends ChangeNotifier {
  static const _methodChannel = MethodChannel('dk.wejeo.sejerslevDemo/tuya');

  Future<List<Map<String, dynamic>>?> getHomeList() async {
    try {
      var result = await _methodChannel.invokeMethod<String?>('getHomeList');
      // print('result:');
      // print('$result');
      List<dynamic> resultList = [];
      if (result != null) {
        resultList = jsonDecode(result);
      }
      List<Map<String, dynamic>> mapResult = resultList.map((e) => e as Map<String, dynamic>).toList();

      return mapResult;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<int> addHome(
    String homeName,
    String geoName,
    String roomName,
    double lat,
    double lon,
    void Function(int homeId) successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      Map<String, dynamic> args = {
        'homeName': homeName,
        'geoName': geoName,
        'roomName': roomName,
        'lat': lat,
        'lon': lon,
      };
      final int result = await _methodChannel.invokeMethod('addHome', args);
      successCallback(result);
      return result;
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error: $e');
      return -1;
    }
  }

  Future<void> removeHome(
    int homeId,
    void Function() successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      var result = await _methodChannel.invokeMethod<String?>('removeHome', homeId);
      if (result == 'Success') {
        successCallback();
      } else {
        errorCallback('$result, try again.');
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error: $e');
    }
  }

  Future<String?> getWifiName() async {
    try {
      String? ssid;
      final NetworkInfo networkInfo = NetworkInfo();
      if (Platform.isIOS) {
        LocationAuthorizationStatus status = await networkInfo.getLocationServiceAuthorization();
        print('initail status: $status');
        if (status == LocationAuthorizationStatus.notDetermined) {
          // print('Requesting location...');
          status = await networkInfo.requestLocationServiceAuthorization();
          print('Status now: $status');
        }
        if (status == LocationAuthorizationStatus.authorizedAlways || status == LocationAuthorizationStatus.authorizedWhenInUse) {
          ssid = await networkInfo.getWifiName();
        } else {
          print('location service is not authorized, the data might not be correct');
          ssid = await networkInfo.getWifiName();
        }
      } else {
        ssid = await networkInfo.getWifiName();
      }

      return ssid;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> startParing(
    int homeId,
    String ssid,
    String password,
    void Function(String deviceId) successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      Map<String, dynamic> args = {
        'homeId': homeId,
        // 'password': 'JJ20120902',
        // 'password': '749dfd196',
        'password': password,
        'ssid': ssid, //'Schmidt2',
      };
      print(args);
      String result = await _methodChannel.invokeMethod('startParing', args);
      var resultList = result.split(':');
      if (resultList.length > 1) {
        if (resultList[0] == 'Success') {
          successCallback(resultList[1]);
        } else {
          errorCallback('$result, try again.');
        }
      } else {
        errorCallback('$result, try again.');
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error paring: $e');
    }
  }

  Future<void> stopParing() async {
    try {
      await _methodChannel.invokeMethod('stopParing');
      print("Stopped Paring");
    } on PlatformException catch (e) {
      print('Error: $e');
    }
  }

  Future<void> setCurrentHome(int homeId) async {
    try {
      await _methodChannel.invokeMethod('setCurrentHome', homeId);
    } on PlatformException catch (e) {
      print('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>?> getCurrentHomeDeviceList() async {
    try {
      // Map<String, dynamic>? result = await platform.invokeMethod('getCurrentHomeDeviceList');
      var result = await _methodChannel.invokeMethod<String?>('getCurrentHomeDeviceList');
      List<dynamic> resultList = [];
      if (result != null) {
        resultList = jsonDecode(result);
      }
      List<Map<String, dynamic>> mapResult = resultList.map((e) => e as Map<String, dynamic>).toList();
      return mapResult;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getDeviceListFromHomeId(int homeId) async {
    try {
      // Map<String, dynamic>? result = await platform.invokeMethod('getCurrentHomeDeviceList');
      var result = await _methodChannel.invokeMethod<String?>('getDeviceListFromHomeId', homeId);
      List<dynamic> resultList = [];
      if (result != null) {
        resultList = jsonDecode(result);
      }
      List<Map<String, dynamic>> mapResult = resultList.map((e) => e as Map<String, dynamic>).toList();
      return mapResult;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<bool?> setDeviceValue(String deviceId, String dpId) async {
    try {
      Map<String, dynamic> args = {
        'deviceId': deviceId,
        'dpId': dpId,
      };
      var result = await _methodChannel.invokeMethod<bool?>('setDeviceValue', args);
      return result;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> readDeviceValues(String deviceId, String dpId) async {
    try {
      var result = await _methodChannel.invokeMethod<String?>('readDeviceValues', deviceId);
      Map<String, dynamic> resultMap = {};
      if (result != null) {
        resultMap = jsonDecode(result);
        print(resultMap);
      }
      return resultMap;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Stream<Map<String, dynamic>>? deviceValueStream() {
    try {
      const deviceEventChannel = EventChannel('dk.wejeo.sejerslevDemo/deviceEvents');
      final networkStream =
          deviceEventChannel.receiveBroadcastStream().distinct().map((dynamic event) => jsonDecode(event ?? '{}') as Map<String, dynamic>);
      return networkStream;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getDeviceProperties(String deviceId) async {
    try {
      var result = await _methodChannel.invokeMethod<String?>('getDeviceProperties', deviceId);
      List<dynamic> resultList = [];
      if (result != null) {
        resultList = jsonDecode(result);
      }
      List<Map<String, dynamic>> mapResult = resultList.map((e) => e as Map<String, dynamic>).toList();
      return mapResult;
    } on PlatformException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> removeDevice(
    String deviceId,
    void Function(String message) successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      var result = await _methodChannel.invokeMethod<String?>('removeDevice', deviceId);
      if (result == 'Success') {
        successCallback("Device has been removed");
      } else {
        errorCallback('$result, try again.');
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error removing device: $e.');
    }
  }
}
