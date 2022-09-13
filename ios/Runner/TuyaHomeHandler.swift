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
///
///Access Tuya platform functions
///
class TuyaHomeHandler : NSObject{
    
    static let sharedInstance = TuyaHomeHandler()
    
    let homeManager: TuyaSmartHomeManager
    let tuyaActivator: TuyaSmartActivator
    var currentHome: TuyaSmartHome?
    var flutterResult: FlutterResult?
    var smartDevice :TuyaSmartDevice?
    
    override
    private init(){
        self.homeManager = TuyaSmartHomeManager()
        self.tuyaActivator = TuyaSmartActivator.sharedInstance()
        super.init()
        if LocalDataHandler.currentHomeId != nil {
            self.currentHome = TuyaSmartHome(homeId: LocalDataHandler.currentHomeId!)
            self.initHome(homeId: LocalDataHandler.currentHomeId!)
        }
        
    }
    
    ///
    ///Create a home
    ///
    public func addHome(result:@escaping FlutterResult, homeName: String, geoName: String, roomName: String, lat: Double, lon: Double) {
        
        self.homeManager.addHome(withName: homeName,
                                 geoName: geoName,
                                 rooms: [roomName],
                                 latitude: lat,
                                 longitude: lon,
                                 success: { (homeId) in
            LocalDataHandler.currentHomeId = homeId
            self.initHome(homeId: homeId)
            result(homeId)
        }) { (error) in
            if let e = error {
                result(FlutterError.init(code: " tuyaFailureError", message: "Add home failed: \(e)", details: nil))
            }
        }
    }
    public func removeHome(result:@escaping FlutterResult, homeId: Int64) {
        
        self.currentHome?.dismiss(success: {
            let message = "Success"
            result(message)
        }) { (error) in
            if let e = error {
                result(FlutterError.init(code: " tuyaFailureError", message: "Add home failed: \(e)", details: nil))
            }
        }
    }
    
    ///
    ///Get list of homes
    ///
    public func getHomeList(result:@escaping FlutterResult) {
        
        
        self.homeManager.getHomeList(success: { (homes) in
            
            guard let myHomes = homes else{
                result(nil)
                print("nil Homes")
                return
            }
            let homeDictList = myHomes.reduce(into: [[AnyHashable: Any]]()) { array, value in
                array.append(["name": value.name!, "homeId" : value.homeId])
            }
            
            result(homeDictList.toJSONString())
        }) { (error) in
            if let e = error {
                result(FlutterError.init(code: " tuyaFailureError", message: "Get home list failed: \(e)", details: nil))
            }
        }
    }
    
    
    public func setCurrentHome(result:@escaping FlutterResult, homeId:Int64) {
        LocalDataHandler.currentHomeId = homeId;
        self.initHome(homeId: homeId)
    }
    
    
    
    
    
    
}


extension TuyaHomeHandler: TuyaSmartHomeDelegate {
    
    func initHome(homeId:Int64) {
        self.currentHome = TuyaSmartHome(homeId: homeId)
        self.currentHome?.delegate = self
    }
    
    // Home information such as a home name is changed.
    func homeDidUpdateInfo(_ home: TuyaSmartHome!) {
        //        reload()
        print("Home info update...")
    }
    
    // The list of shared devices is updated.
    func homeDidUpdateSharedInfo(_ home: TuyaSmartHome!) {
        print("Home shared info update...")
    }
    
    // A room is added to the home.
    func home(_ home: TuyaSmartHome!, didAddRoom room: TuyaSmartRoomModel!) {
        //...
        print("Home room added ...")
    }
    
    // A room is removed from the home.
    private func home(_ home: TuyaSmartHome!, didRemoveRoom roomId: Int32!) {
        //...
        print("Home room removed...")
    }
    
    // Room information such as a room name is changed.
    func home(_ home: TuyaSmartHome!, roomInfoUpdate room: TuyaSmartRoomModel!) {
        //        reload()/
        print("Home room info update...")
    }
    
    // The mappings between rooms and devices or groups are updated.
    func home(_ home: TuyaSmartHome!, roomRelationUpdate room: TuyaSmartRoomModel!) {
        print("Home room relation update...")
    }
    
    // A device is added.
    func home(_ home: TuyaSmartHome!, didAddDeivice device: TuyaSmartDeviceModel!) {
        print("Home device added...")
    }
    
    // A device is removed.
    func home(_ home: TuyaSmartHome!, didRemoveDeivice devId: String!) {
        print("Home device removed...")
    }
    
    // Device information such as a device name is changed.
    func home(_ home: TuyaSmartHome!, deviceInfoUpdate device: TuyaSmartDeviceModel!) {
        print("Home device info update...")
    }
    
    // Device DPs are updated for the home.
    func home(_ home: TuyaSmartHome!, device: TuyaSmartDeviceModel!, dpsUpdate dps: [AnyHashable : Any]!) {
        //...
        print("Home device DP update...")
    }
    
    // A group is added.
    func home(_ home: TuyaSmartHome!, didAddGroup group: TuyaSmartGroupModel!) {
        print("Home group added...")
    }
    
    // A group is removed.
    func home(_ home: TuyaSmartHome!, didRemoveGroup groupId: String!) {
        print("Home remove group...")
    }
    
    // Group information such as a group name is changed.
    func home(_ home: TuyaSmartHome!, groupInfoUpdate group: TuyaSmartGroupModel!) {
        print("Home group info update ...")
    }
    
    // Group DPs are updated for the home.
    func home(_ home: TuyaSmartHome!, group: TuyaSmartGroupModel!, dpsUpdate dps: [AnyHashable : Any]!) {
        //...
        print("Home group DP update...")
    }
    
    // Device alerts are updated for the home.
    func home(_ home: TuyaSmartHome!, device: TuyaSmartDeviceModel!, warningInfoUpdate warningInfo: [AnyHashable : Any]!) {
        //...
        print("Home device alerts update...")
    }
    
    // Device update status is changed for the home.
    func home(_ home: TuyaSmartHome!, device: TuyaSmartDeviceModel!, upgradeStatus status: TuyaSmartDeviceUpgradeStatus) {
        //....
        print("Home device update status...")
    }
    
}
