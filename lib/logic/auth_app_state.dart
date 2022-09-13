import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppLoginState {
  loggedIn,
  loggedOut,
}

class AuthAppState extends ChangeNotifier {
  static const _methodChannel = MethodChannel('dk.wejeo.sejerslevDemo/tuya');

  AppLoginState _loginState = AppLoginState.loggedOut;
  AppLoginState get loginState => _loginState;

  AuthAppState() {
    checkLogin();
  }

  Future<void> checkLogin() async {
    try {
      final bool result = await _methodChannel.invokeMethod('checkIsLoggedIn');
      if (result) {
        _loginState = AppLoginState.loggedIn;
      } else {
        _loginState = AppLoginState.loggedOut;
      }
    } on PlatformException catch (e) {
      print(e);
      _loginState = AppLoginState.loggedOut;
    }
    notifyListeners();
  }

  Future<void> loginWithEmail(
    String email,
    String password,
    String countryCode,
    void Function() successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      Map<String, dynamic> args = {
        'email': email,
        'password': password,
        'countryCode': countryCode,
      };
      final String? result = await _methodChannel.invokeMethod('loginWithEmail', args);
      print('Result: $result');
      if (result != null) {
        if (result == 'Success') {
          await checkLogin();
          successCallback();
        } else {
          errorCallback(result);
        }
      } else {
        errorCallback('Something went wrong');
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      print(e.code);
      print(e.details);
      errorCallback('${e.message}');
    }
  }

  Future<void> logOutUser(
    void Function() successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      final String? result = await _methodChannel.invokeMethod('logOutUser');
      print('Result: $result');
      if (result != null) {
        if (result == 'Success') {
          await checkLogin();
          successCallback();
        } else {
          errorCallback(result);
        }
      } else {
        errorCallback('Something went wrong');
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('${e.message}');
    }
  }

  Future<void> sendVerificationCode(
    String email,
    String countryCode,
    void Function() successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      Map<String, dynamic> args = {
        'email': email,
        'countryCode': countryCode,
      };
      final String result = await _methodChannel.invokeMethod('sendVerificationCode', args);
      print('Result: $result');
      if (result == 'Success') {
        successCallback();
      } else {
        errorCallback(result);
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error: $e');
    }
  }

  Future<void> checkVerificationCode(
    String email,
    String countryCode,
    String verificationCode,
    void Function() successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      Map<String, dynamic> args = {
        'email': email,
        'countryCode': countryCode,
        'verificationCode': verificationCode,
      };
      final String result = await _methodChannel.invokeMethod('checkVerificationCode', args);
      print('Result: $result');
      if (result == 'Success') {
        successCallback();
      } else {
        errorCallback(result);
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error: $e');
    }
  }

  Future<void> registerUser(
    String email,
    String password,
    String countryCode,
    String verificationCode,
    void Function() successCallback,
    void Function(String message) errorCallback,
  ) async {
    try {
      Map<String, dynamic> args = {
        'email': email,
        'countryCode': countryCode,
        'password': password,
        'verificationCode': verificationCode,
      };
      final String result = await _methodChannel.invokeMethod('registerUser', args);
      print('Result: $result');
      if (result == 'Success') {
        await checkLogin();
        successCallback();
      } else {
        errorCallback(result);
      }
    } on PlatformException catch (e) {
      print('Error: $e');
      errorCallback('Error: $e');
    }
  }
}
