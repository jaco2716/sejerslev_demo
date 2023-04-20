# Sejerslev Demo
## Commands
### Build JsonSerializable model classes:
* flutter pub run build_runner build
* flutter pub run build_runner watch

### Build iOS/Android Archive: 
Remember to change version!
* flutter build ipa
* flutter build appbundle

### Google Cloud Platform
Restore backup
* gcloud firestore import gs://ab_one_firestore_backup/[EXPORT FOLDER NAME]

---
## TUYA IOS SDK SETUP


* Update CocoaPods to the latest version. 
[sudo] gem install cocoapods

* Add the following code block to the Podfile:
```
source 'https://cdn.cocoapods.org/'
source 'https://github.com/TuyaInc/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'
platform :ios, '11.0'

target 'Your_Project_Name' do
    Pod 'TuyaSmartHomeKit','~> 4.0.0'
end
```
In the root directory of your project, run pod update.

### Initialize the SDK

1) Make sure bundle id is the same as in Tuya setup.
2) Import the security image to the root directory (Runner folder) of the project, and rename it as t_s.bmp. 
3) Go to Project Settings > Target > Build Phases, and add this image to Copy Bundle Resources. (May be there already)
4) Dont: (Add the following content to the PrefixHeader.pch file:
- #import <TuyaSmartHomeKit/TuyaSmartKit.h>)
5) Add the following content to the bridging header file xxx_Bridging-Header.h:
- #import <TuyaSmartHomeKit/TuyaSmartKit.h>
6) Open the AppDelegate.swift file and initialize the SDK in AppDelegate application:didFinishLaunchingWithOptions:.
### Configure the SDK
Define values:
```
  let tuyaUserHandler = TuyaUserHandler.sharedInstance
  let tuyaHomeHandler = TuyaHomeHandler.sharedInstance
  let tuyaDeviceHandler = TuyaDeviceHandler.sharedInstance
```
Insert into AppDelegate.swift - func application (Replace BUNDLE_ID):
```
    //Flutter Method Channel
    let deviceEventChannelName = "dk.wejeo.BUNDLE_ID/deviceEvents"
    let tuyaChannelName = "dk.wejeo.BUNDLE_ID/tuya"
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let tuyaChannel = FlutterMethodChannel(name: tuyaChannelName, binaryMessengercontroller.    binaryMessenger)
    tuyaChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping   FlutterResult) -> Void in
        self.checkMethodChannel(call: call, result: result)
    })
    
    let deviceChannel = FlutterEventChannel(name: deviceEventChannelNamebinaryMessenger:    controller.binaryMessenger)
    deviceChannel.setStreamHandler(tuyaDeviceHandler)
    
    // Initialize TuyaSmartSDK
    TuyaSmartSDK.sharedInstance().start(withAppKey: AppKey.appKey, secretKey: AppKesecretKey)
    
    // Enable debug mode, which allows you to see logs.
    #if DEBUG
          TuyaSmartSDK.sharedInstance().debugMode = true
    #endif
```
Create AppKey.swift file and pase code(Change values to your key and secret):
```
    import Foundation
    struct AppKey {
        static let appKey = "YOUR_APP_KEY"
        static let secretKey = "YOUR_APP_SECRET"
    }
```
---