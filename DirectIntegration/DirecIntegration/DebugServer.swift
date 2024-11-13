//
//  DebugServer.swift
//  DirectIntegration
//
//  Created by Tomaz Treven on 13. 8. 24.
//

import Foundation
import Network
import NeftaSDK

@objc class DebugServer : NSObject {

    let _endpoint: NWEndpoint.Host
    let _port: NWEndpoint.Port
    let _serial: String
    
    var _connection: NWConnection?
    
    @objc init(ip: String, serial: String) {
        _endpoint = NWEndpoint.Host(ip)
        _port = NWEndpoint.Port(rawValue: 12012)!
        _serial = serial
        
        super.init()
        
        startServer()
    }
    
    func startReceiving() {
        _connection!.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let message = String(data: data, encoding: .utf8) ?? "Invalid data"
                
                var control = message
                let controlEnd = message.firstIndex(of: " ")
                if let cE = controlEnd {
                    control = String(message[...message.index(before: cE)])
                }
                switch control {
                case "get_nuid":
                    _ = NeftaPlugin._instance.GetNuid(present: false)
                    break
                case "set_time_offset":
                    let offsetString = String(message[message.index(after: controlEnd!)...])
                    if let offset = Int(offsetString) {
                        NeftaPlugin.SetDebugTime(offset: offset)
                    }
                    self.send(message: "return set_time_offset")
                    break
                case "ad_units":
                    var adUnits = [[String: Any]]()
                    if let placements = NeftaPlugin._instance!._placements {
                        for (id, placement) in placements {
                            var adUnit : [String: Any] = [
                                "id": id,
                                "type": placement._type.description
                            ]
                            
                            var ads = [[String: Any]]()
                            for ad in NeftaPlugin._instance._ads {
                                var creativeId = ""
                                if let bid = ad._bid, let crid = bid._creativeId {
                                    creativeId = crid
                                }
                                ads.append([
                                    "id": String(ad.hashValue),
                                    "crid": creativeId,
                                    "state": ad._state
                                ])
                            }
                            adUnit["ads"] = ads
                            adUnits.append(adUnit)
                        }
                    }
                    let payload: [String: Any] = [
                        "ad_units": adUnits
                    ]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                        self.send(message: "return ad_units \(String(data: jsonData, encoding: .utf8)!)")
                    } catch _ as NSError {
                        
                    }
                    break
                case "create":
                    let aId = String(message[message.index(after: controlEnd!)...])
                    var adId: Int = 0
                    for (pId, placement) in NeftaPlugin._instance._placements {
                        if pId == aId {
                            if placement._type == .Banner {
                                let banner = NBanner(id: aId, position: NBanner.Position.Top)
                                adId = banner.hashValue
                            } else if (placement._type == .Interstitial) {
                                let interstitial = NInterstitial(id: aId)
                                adId = interstitial.hashValue
                            } else if (placement._type == .Rewarded) {
                                let rewarded = NRewarded(id: aId)
                                adId = rewarded.hashValue
                            }
                            break
                        }
                    }
                    self.send(message: "return create \(adId)")
                    break
                case "partial_bid":
                    do {
                        var bidResponse : String = ""
                        let aIdString = String(message[message.index(after: controlEnd!)...])
                        let aId = Int(aIdString)
                        for ad in NeftaPlugin._instance._ads {
                            if ad.hashValue == aId {
                                let payload = ad.GetPartialBidRequest()!
                                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                                bidResponse = String(data: jsonData, encoding: .utf8)!
                                break
                            }
                        }
                        self.send(message: "return partial_bid \(aIdString) \(bidResponse)")
                    } catch _ as NSError {
                        
                    }
                    break;
                case "bid":
                    let aIdString = String(message[message.index(after: controlEnd!)...])
                    let aId = Int(aIdString)
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == aId {
                            ad.Bid()
                            break
                        }
                    }
                    self.send(message: "return bid \(aIdString)")
                    break
                case "custom_load":
                    let aIdStart = message.index(after: controlEnd!)
                    let temp = String(message[aIdStart...])
                    let pIdEnd = temp.firstIndex(of: " ")!
                    let aIdString = String(temp[...temp.index(before:pIdEnd)])
                    let aId = Int(aIdString)
                    let bidResponse = String(temp[temp.index(after:pIdEnd)...]).data(using: .utf8)!
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == aId {
                            ad.LoadWithBidResponse(bidResponse: bidResponse)
                            break
                        }
                    }
                    self.send(message: "return custom_load \(aIdString)")
                    break;
                case "load":
                    let aIdString = String(message[message.index(after: controlEnd!)...])
                    let aId = Int(aIdString)
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == aId {
                            ad.Load()
                            break
                        }
                    }
                    self.send(message: "return load \(aIdString)")
                    break
                case "show":
                    let aIdString = String(message[message.index(after: controlEnd!)...])
                    let aId = Int(aIdString)
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == aId {
                            DispatchQueue.main.async {
                                ad.Show()
                            }
                            break
                        }
                    }
                    self.send(message: "return show \(aIdString)")
                    break
                case "add_event":
                    let parameters = String(message[message.index(after: controlEnd!)...]).split(separator: " ").map { String($0) }
                    var name : String?
                    var value: Int = 0
                    var customPayload : String?
                    if parameters[0] == "progression" {
                        let status = self.ToProgressionStatus(parameters[1])
                        let type = self.ToProgressionType(parameters[2])
                        let source = self.ToProgressionSource(parameters[3])
                        if parameters.count > 4 {
                            name = parameters[4]
                        }
                        if parameters.count > 5 {
                            value = Int(parameters[5])!
                        }
                        if parameters.count > 6 {
                            customPayload = parameters[6]
                        }
                        NeftaPlugin._instance.Events.AddProgressionEvent(status: status, type: type, source: source, name: name, value: value, customPayload: customPayload)
                    } else if parameters[0] == "receive" {
                        let category = self.ToResourceCategory(parameters[1])
                        let method = self.ToReceiveMethod(parameters[2])
                        if (parameters.count > 3) {
                            name = parameters[3]
                        }
                        if parameters.count > 4 {
                            value = Int(parameters[4])!
                        }
                        if parameters.count > 5 {
                            customPayload = parameters[5]
                        }
                        NeftaPlugin._instance.Events.AddReceiveEvent(category: category, method: method, name: name, quantity: value, customPayload: customPayload)
                    } else if parameters[0] == "spend" {
                        let category = self.ToResourceCategory(parameters[1])
                        let method = self.ToSpendMethod(parameters[2])
                        if (parameters.count > 3) {
                            name = parameters[3]
                        }
                        if parameters.count > 4 {
                            value = Int(parameters[4])!
                        }
                        if parameters.count > 5 {
                            customPayload = parameters[5]
                        }
                        NeftaPlugin._instance.Events.AddSpendEvent(category: category, method: method, name: name, quantity: value, customPayload: customPayload)
                    }
                    self.send(message: "return add_event")
                    break
                case "set_override":
                    let override = String(message[message.index(after: controlEnd!)...])
                    NeftaPlugin._instance.SetOverride(url: override)
                    self.send(message: "return set_override")
                    break
                default:
                    print("DS:Unrecognized command: \(control)")
                    break
                }
            }
            self.startReceiving()
        }
    }
    
    @objc func send(message: String) {
        if let connection = _connection {
            let payload = "\(_serial) \(message)`"
            connection.send(content: payload.data(using: .utf8), completion: .contentProcessed { error in
            })
        }
    }
    
    private func startServer() {
        _connection = NWConnection(host: _endpoint, port: _port, using: .tcp)
        _connection!.stateUpdateHandler = { state in
            switch state {
            case .ready:
                self.send(message: "log Debug server connected")
                print("DS:Connection established")
                self.startReceiving()
            case .failed(let error):
                print("DS:Connection failed: \(error)")
                self.restartServer()
            case .cancelled:
                print("DS:Connection cancelled")
                self.restartServer()
            default:
                print("DS: \(state)")
                break
            }
        }
        _connection!.start(queue: DispatchQueue(label: "DS", attributes: .concurrent))
        send(message: "log Debug server connected")
    }
    
    private func restartServer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.startServer()
        }
    }
    
    private func ToProgressionStatus(_ name: String) -> NeftaEvents.ProgressionStatus {
        switch name {
            case "start":
                return NeftaEvents.ProgressionStatus.Start
            case "complete":
                return NeftaEvents.ProgressionStatus.Complete
            default:
                return NeftaEvents.ProgressionStatus.Fail
        }
    }
    
    private func ToProgressionType(_ name: String) -> NeftaEvents.ProgressionType {
        switch name {
            case "achievement":
                return .Achievement
            case "gameplay_unit":
                return .GameplayUnit
            case "item_level":
                return .ItemLevel
            case "unlock":
                return .Unlock
            case "player_level":
                return .PlayerLevel
            case "task":
                return .Task
            default:
                return .Other
        }
    }
    
    private func ToProgressionSource(_ name: String?) -> NeftaEvents.ProgressionSource {
        switch name {
            case nil:
                return NeftaEvents.ProgressionSource.Undefined
            case "core_content":
                return NeftaEvents.ProgressionSource.CoreContent
            case "optional_content":
                return NeftaEvents.ProgressionSource.OptionalContent
            case "boss":
                return NeftaEvents.ProgressionSource.Boss
            case "social":
                return NeftaEvents.ProgressionSource.Social
            case "special_event":
                return NeftaEvents.ProgressionSource.SpecialEvent
            default:
                return NeftaEvents.ProgressionSource.Other
        }
    }
    
    private func ToResourceCategory(_ name: String) -> NeftaEvents.ResourceCategory {
        switch name {
            case "soft_currency":
                return NeftaEvents.ResourceCategory.SoftCurrency
            case "premium_currency":
                return NeftaEvents.ResourceCategory.PremiumCurrency
            case "resource":
                return NeftaEvents.ResourceCategory.Resource
            case "consumable":
                return NeftaEvents.ResourceCategory.Consumable
            case "cosmetic_item":
                return NeftaEvents.ResourceCategory.CosmeticItem
            case "core_item":
                return NeftaEvents.ResourceCategory.CoreItem
            case "chest":
                return NeftaEvents.ResourceCategory.Chest
            case "experience":
                return NeftaEvents.ResourceCategory.Experience
            default:
                return NeftaEvents.ResourceCategory.Other
        }
    }
    
    private func ToReceiveMethod(_ name: String?) -> NeftaEvents.ReceiveMethod {
        switch name {
            case nil:
                return NeftaEvents.ReceiveMethod.Undefined
            case "level_end":
                return NeftaEvents.ReceiveMethod.LevelEnd
            case "reward":
                return NeftaEvents.ReceiveMethod.Reward
            case "loot":
                return NeftaEvents.ReceiveMethod.Loot
            case "shop":
                return NeftaEvents.ReceiveMethod.Shop
            case "iap":
                return NeftaEvents.ReceiveMethod.Iap
            case "create":
                return NeftaEvents.ReceiveMethod.Create
            default:
                return NeftaEvents.ReceiveMethod.Other
        }
    }
    
    private func ToSpendMethod(_ name: String?) -> NeftaEvents.SpendMethod {
        switch name {
            case nil:
                return NeftaEvents.SpendMethod.Undefined
            case "boost":
                return NeftaEvents.SpendMethod.Boost
            case "continuity":
                return NeftaEvents.SpendMethod.Continuity
            case "create":
                return NeftaEvents.SpendMethod.Create
            case "unlock":
                return NeftaEvents.SpendMethod.Unlock
            case "upgrade":
                return NeftaEvents.SpendMethod.Upgrade
            case "shop":
                return NeftaEvents.SpendMethod.Shop
            default:
                return NeftaEvents.SpendMethod.Other
        }
    }
}
