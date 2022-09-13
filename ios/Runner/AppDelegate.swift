import UIKit
import Flutter
import TuyaSmartBaseKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    let tuyaUserHandler = TuyaUserHandler.sharedInstance
    let tuyaHomeHandler = TuyaHomeHandler.sharedInstance
    let tuyaDeviceHandler = TuyaDeviceHandler.sharedInstance
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        //Flutter Method Channel
        let deviceEventChannelName = "dk.wejeo.sejerslevDemo/deviceEvents"
        let tuyaChannelName = "dk.wejeo.sejerslevDemo/tuya"
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let tuyaChannel = FlutterMethodChannel(name: tuyaChannelName, binaryMessenger: controller.binaryMessenger)
        tuyaChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self.checkMethodChannel(call: call, result: result)
        })
        
        let deviceChannel = FlutterEventChannel(name: deviceEventChannelName, binaryMessenger: controller.binaryMessenger)
        deviceChannel.setStreamHandler(tuyaDeviceHandler)
        
        // Initialize TuyaSmartSDK
        TuyaSmartSDK.sharedInstance().start(withAppKey: AppKey.appKey, secretKey: AppKey.secretKey)
        
        // Enable debug mode, which allows you to see logs.
#if DEBUG
        TuyaSmartSDK.sharedInstance().debugMode = true
#endif
        
        //        GeneratedPluginRegistrant.register(with: self)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    ///
    ///Handle Flutter method call
    ///
    private func checkMethodChannel(call: FlutterMethodCall, result: @escaping FlutterResult){
        // This method is invoked on the UI thread.
        if (call.method == "checkIsLoggedIn"){
            tuyaUserHandler.checkIsLoggedIn(result: result)
            
        } else if (call.method == "loginWithEmail"){
            if let args = call.arguments as? Dictionary<String, Any>,
               let email = args["email"] as? String,
               let password = args["password"] as? String,
               let countryCode = args["countryCode"] as? String {
                tuyaUserHandler.loginWithEmail(result: result, countryCode: countryCode, email: email, password: password)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "logOutUser"){
                tuyaUserHandler.logOutUser(result: result)
           
        } else if (call.method == "sendVerificationCode"){
            if let args = call.arguments as? Dictionary<String, Any>,
               let email = args["email"] as? String,
               let countryCode = args["countryCode"] as? String {
                tuyaUserHandler.sendVerificationCode(result: result, countryCode: countryCode, email: email)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "checkVerificationCode"){
            if let args = call.arguments as? Dictionary<String, Any>,
               let email = args["email"] as? String,
               let countryCode = args["countryCode"] as? String,
               let verificationCode = args["verificationCode"] as? String {
                tuyaUserHandler.checkVerificationCode(result: result, countryCode: countryCode, email: email, verificationCode: verificationCode)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "registerUser"){
            if let args = call.arguments as? Dictionary<String, Any>,
               let email = args["email"] as? String,
               let password = args["password"] as? String,
               let verificationCode = args["verificationCode"] as? String,
               let countryCode = args["countryCode"] as? String {
                tuyaUserHandler.registerUser(result: result, countryCode: countryCode, email: email, password: password, verificationCode: verificationCode)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "getHomeList"){
            tuyaHomeHandler.getHomeList(result: result)
            
        } else if (call.method == "addHome"){
            if let args = call.arguments as? Dictionary<String, Any>,
               let homeName = args["homeName"] as? String,
               let geoName = args["geoName"] as? String,
               let roomName = args["roomName"] as? String,
               let lat = args["lat"] as? Double,
               let lon = args["lon"] as? Double {
                tuyaHomeHandler.addHome(result: result, homeName: homeName, geoName: geoName, roomName: roomName, lat: lat, lon: lon)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
        } else if (call.method == "startParing"){
            if let args = call.arguments as? Dictionary<String, Any>,
               let homeId = args["homeId"] as? Int64,
               let password = args["password"] as? String,
               let ssid = args["ssid"] as? String {
                tuyaDeviceHandler.startParing(result: result, homeId: homeId, password: password, ssid: ssid)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
        } else if (call.method == "stopParing"){
            tuyaDeviceHandler.stopParing()
            
        }
        else if (call.method == "getCurrentHomeDeviceList"){
            tuyaDeviceHandler.getCurrentHomeDeviceList(result: result)
            
        } else if (call.method == "setCurrentHome"){
            if let homeId = call.arguments as? Int64 {
                tuyaHomeHandler.setCurrentHome(result: result, homeId: homeId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "getDeviceListFromHomeId"){
            if let homeId = call.arguments as? Int64 {
                tuyaDeviceHandler.getDeviceListFromHomeId(result: result, homeId: homeId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "setDeviceValue"){
            if  let args = call.arguments as? Dictionary<String, Any>,
                let deviceId = args["deviceId"] as? String,
                let dpId = args["dpId"] as? String{
                
                tuyaDeviceHandler.setDeviceValue(result: result, deviceId: deviceId, dpId: dpId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "readDeviceValues"){
            if  let deviceId = call.arguments as? String{
                tuyaDeviceHandler.readDeviceValues(result: result, deviceId: deviceId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "getDeviceProperties"){
            if let deviceId = call.arguments as? String {
                tuyaDeviceHandler.getDeviceProperties(result: result, deviceId: deviceId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "removeDevice"){
            if let deviceId = call.arguments as? String {
                tuyaDeviceHandler.removeDevice(result: result, deviceId: deviceId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else if (call.method == "removeHome"){
            if let homeId = call.arguments as? Int64 {
                tuyaHomeHandler.removeHome(result: result, homeId: homeId)
            } else {
                result(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
            }
            
        } else {
            result(FlutterMethodNotImplemented)
            return
        }
    }
  
}


