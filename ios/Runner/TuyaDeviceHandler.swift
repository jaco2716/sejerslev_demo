//
//  TuyaDeviceHandler.swift
//  Runner
//
//  Created by Jacob Welin - Wejeo on 10/09/2022.
//

import Foundation
//
//  TuyaHandler.swift
//  Runner
//
//  Created by Jacob Welin - Wejeo on 05/09/2022.
//

import Foundation
import Flutter
import TuyaSmartBaseKit
import TuyaSmartActivatorKit
import YYModel
///
///Access Tuya platform functions
///
class TuyaDeviceHandler : NSObject{
    
    static let sharedInstance = TuyaDeviceHandler()
    
    var flutterResult: FlutterResult?
    let tuyaActivator: TuyaSmartActivator
    var smartDevice :TuyaSmartDevice?
    private var eventSink: FlutterEventSink?
    
    override
    private init(){
        self.tuyaActivator = TuyaSmartActivator.sharedInstance()
        super.init()
        if LocalDataHandler.currentDeviceId != nil {
            self.smartDevice = TuyaSmartDevice(deviceId: LocalDataHandler.currentDeviceId!)
            self.initDevice(deviceId: LocalDataHandler.currentDeviceId!)
        }
        
        
    }
    
    //--------------------------------------------------------------------------
    //Paring device
    public func startParing(result:@escaping FlutterResult, homeId: Int64, password: String, ssid: String){
        
        print("Started Paring device: homeId: \(homeId), password: \(password), ssid: \(ssid)")
        self.getToken(result: result, homeId: homeId, ssid: ssid, password: password)
    }
    
    private func getToken(result:@escaping FlutterResult, homeId: Int64, ssid: String, password: String) {
        tuyaActivator.getTokenWithHomeId(homeId, success: { (token) in
            // TODO: startConfigWiFi
            if(token == nil){
                print("Cant get Token")
            }
            print("Got token: \(token ?? "Null")")
            self.startConfigWiFi(result: result, withSsid: ssid, password: password, token: token!)
        }, failure: { (error) in
            if let e = error {
                print("getToken failure: \(e)")
            }
        })
    }
    
    private func startConfigWiFi(result:@escaping FlutterResult, withSsid ssid: String, password: String, token: String) {
        print("Getting TuyaSmartActivator")
        // Implements the delegate method of `TuyaSmartActivator`.
        tuyaActivator.delegate = self
        print("Starting config")
        // Starts pairing.
        tuyaActivator.startConfigWiFi(TYActivatorMode.EZ, ssid: ssid, password: password, token: token, timeout: 100)
        print("Config Done")
        flutterResult = result
    }
    private func returnDevicePairResult(message: String){
        self.flutterResult?(message)
    }
    
    
    public func stopParing() {
        print("Stopping config")
        tuyaActivator.delegate = nil
        tuyaActivator.stopConfigWiFi()
    }
    
    
    //--------------------------------------------------------------------------
    //Handle devices
    
    public func getCurrentHomeDeviceList(result:@escaping FlutterResult){
        guard let currentHome = TuyaHomeHandler.sharedInstance.currentHome else{
            result("nil home")
            return
        }
        
        currentHome.getDataWithSuccess( { (home) in
            // The value of `homeId` for the home.
            
            guard let deviceList = currentHome.deviceList else {
                print("Get Device failed")
                result(nil)
                return
            }
            print(deviceList)
            let deviceDictList = deviceList.reduce(into: [[AnyHashable: Any]]()) { array, value in
                array.append(["name": value.name!, "devId" : value.devId!])
            }
            
            print(deviceDictList)
            result(deviceDictList.toJSONString())
            
        }, failure: {error in
            print("Failed to get home data")
            result(nil)
        })
        
    }
    
    public func getDeviceListFromHomeId(result:@escaping FlutterResult, homeId: Int64){
        guard let homeFromId = TuyaSmartHome(homeId: homeId) else{
            result("nil home")
            return
        }
        
        homeFromId.getDataWithSuccess( { (home) in
            // The value of `homeId` for the home.
            
            guard let deviceList = homeFromId.deviceList else {
                print("Get Device failed")
                result(nil)
                return
            }
            print(deviceList)
            let deviceDictList = deviceList.reduce(into: [[AnyHashable: Any]]()) { array, value in
                array.append(["name": value.name!, "devId" : value.devId!])
            }
            
            print(deviceDictList)
            result(deviceDictList.toJSONString())
            
        }, failure: {error in
            print("Failed to get home data")
            result(nil)
        })
        
    }
    
    public func getDeviceProperties(result:@escaping FlutterResult, deviceId: String){
        let deviceFromId = TuyaSmartDevice(deviceId: deviceId)
        guard let device = deviceFromId else {
            print("Failed to get device.")
            result(nil)
            return
        }
        LocalDataHandler.currentDeviceId = device.deviceModel.devId
        self.initDevice(deviceId: device.deviceModel.devId)
        self.smartDevice = device
        self.smartDevice?.delegate = self
        guard let schemaArray = device.deviceModel.schemaArray else{
            print("Failed to get schemaArray.")
            result(nil)
            return
        }
        
        
        
        let schemaDictList = schemaArray.reduce(into: [[AnyHashable: Any]]()) { array, value in
//            print("Property\(value.property.yy_modelToJSONString()!)")
            array.append(["code": value.code!,
                          "name":value.name!,
                          "dpId" : value.dpId!,
                          "mode": value.mode!,
                          "type":value.type!,
                          "property": value.property.yy_modelToJSONString()!
                         ])
        }
//        schemaDictList.append(["isOnline" : self.smartDevice?.deviceModel.isOnline ?? false])
        result(schemaDictList.toJSONString())
    }
    
    ///
    ///Set device Value (Only for bool atm.)
    ///
    public func setDeviceValue(result:@escaping FlutterResult, deviceId: String, dpId: String){
        let deviceFromId = TuyaSmartDevice(deviceId: deviceId)
        guard let device = deviceFromId,
              let dps = device.deviceModel.dps else {
            print("Failed to get device/dps.")
            result(nil)
            return
        }
        LocalDataHandler.currentDeviceId = device.deviceModel.devId
        self.initDevice(deviceId: device.deviceModel.devId)
        let isOn = dps[dpId] as? Bool ?? false
        
        let payload : [String: Any] = [dpId:!isOn]
        device.publishDps(payload, success: {
            print("Set dps to \(!isOn)")
            print("isOn: \(!isOn)")
            result(!isOn)
        }, failure: { error in
            print("Failed to publish")
            result(nil)
        })
    }

    public func readDeviceValues(result:@escaping FlutterResult, deviceId: String){
        let deviceFromId = TuyaSmartDevice(deviceId: deviceId)
        guard let device = deviceFromId,
              let dps = device.deviceModel.dps else {
            print("Failed to get device/dps.")
            result(nil)
            return
        }
        LocalDataHandler.currentDeviceId = device.deviceModel.devId
        self.initDevice(deviceId: device.deviceModel.devId)
        result(dps.toJSONString())
//        let valueDict = ["value": dps[dpId]]
//        result(valueDict.toJSONString())
    }
    
   public func removeDevice(result:@escaping FlutterResult, deviceId: String) {
       let deviceFromId = TuyaSmartDevice(deviceId: deviceId)
       guard let device = deviceFromId else {
           print("Failed to get device.")
           result(nil)
           return
       }
       device.remove({
           let message = "Success"
           LocalDataHandler.currentDeviceId = nil
           self.initDevice(deviceId: "")
           result(message)
        }, failure: { (error) in
            if let e = error?.localizedDescription {
                result(FlutterError.init(code: " tuyaFailureError", message: e, details: nil))
            } else{
                result(nil)
            }
        })
    }

       
    
}
extension TuyaDeviceHandler: TuyaSmartActivatorDelegate {
    
    func activator(_ activator: TuyaSmartActivator!, didReceiveDevice deviceModel: TuyaSmartDeviceModel!, error: Error!) {
        print("Paring update...")
        
        if deviceModel != nil && error == nil {
            print("Device paired!")
            print("name: \(deviceModel.name ?? "Null"), name: \(deviceModel.uiName ?? "Null"), ")
            LocalDataHandler.currentDeviceId = deviceModel.devId
            self.initDevice(deviceId: deviceModel.devId)
            self.returnDevicePairResult(message: "Success:\(deviceModel.devId ?? "Null")")
        }
        
        if let e = error {
            print("Failed to pair device!")
            print("\(e)")
            self.returnDevicePairResult(message: "Failed to pair device")
        }
        
    }
}

extension TuyaDeviceHandler: TuyaSmartDeviceDelegate {
    
    func initDevice(deviceId:String){
        self.smartDevice = TuyaSmartDevice(deviceId: deviceId)
        self.smartDevice?.delegate = self
    }
    
    func device(_ device: TuyaSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        guard let eventSink = eventSink,
              var data = device.deviceModel.dps else{
            return
        }
        data["isOnline"] = device.deviceModel.isOnline
        eventSink(data.toJSONString())
    }
    
    func deviceOnlineUpdate(_ device: TuyaSmartDevice) {
        guard let eventSink = eventSink,
              var data = device.deviceModel.dps else{
            return
        }
        data["isOnline"] = device.deviceModel.isOnline
        eventSink(data.toJSONString())
    }
    
}


extension TuyaDeviceHandler: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("Stream started")
        self.eventSink = events
        guard let device = TuyaSmartDevice(deviceId: LocalDataHandler.currentDeviceId ?? "") else{
            print("Device Error: \(LocalDataHandler.currentDeviceId ?? "")")
            return nil
        }
        guard var data = device.deviceModel.dps else{
            print("Data error")
            return nil
        }
        
        data["isOnline"] = device.deviceModel.isOnline
        events(data.toJSONString())
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
            eventSink = nil
            return nil
    }
    
    
}
