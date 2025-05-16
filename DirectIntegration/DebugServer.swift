//
//  DebugServer.swift
//  DirectIntegration
//
//  Created by Tomaz Treven on 13. 8. 24.
//

import Foundation
import Network
import NeftaSDK
import UIKit

@objc class DebugServer : NSObject {

    let _broadcastPort = NWEndpoint.Port(rawValue: 12010)
    
    var _viewController: UIViewController
    
    var _name: String?
    var _version: String?
    
    var _broadcastConnection: NWConnection?
    var _timer: Timer?
    var _logLines: [String] = []
    
    @objc init(viewController: UIViewController) {
        _viewController = viewController
        super.init()

        _name = UIDevice.current.model
        _version = "\(NeftaPlugin._instance._info._bundleVersion).\(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
        
        NeftaPlugin.OnLog = { log in
            self._logLines.append(log)
        }
        
        StartBroadcastServer()
    }
    
    deinit {
        print("DS:deinit")
        StopBroadcastServer()
    }
    
    private func StartBroadcastServer() {
        let params = NWParameters.udp
        params.allowLocalEndpointReuse = true
                
        guard let broadcastIp = GetBroadcastAddress() else {
            print("DS:No wifi")
            return
        }
        
        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host(broadcastIp), port: _broadcastPort!)
        print("DS:Starting broadcast on: \(endpoint)")
        _broadcastConnection = NWConnection(to: endpoint, using: params)
        _broadcastConnection!.stateUpdateHandler = { state in
            switch state {
                case .ready:
                    print("DS:Broadcast started on: \(self._broadcastPort!): \(state)")
                    if let endpoint = self._broadcastConnection!.currentPath?.localEndpoint,
                       case let .hostPort(_, port) = endpoint {
                        self.StartListening(on: port)
                    }
                    self.SendState(connection: self._broadcastConnection!, to: "master")
                case .failed(let error):
                    print("DS:Broadcast failed on: \(error)")
                default:
                    break
            }
        }
        _broadcastConnection!.start(queue: .global())
        
        _timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let connection = self._broadcastConnection {
                self.SendState(connection: connection, to: "master")
            }
        }
    }
    
    private func SendUdp(connection: NWConnection, to: String, message: String) {
        let data = "\(self._name!)|\(to)|\(message)"
        //print("DS:SendBroadcastTo: \(data)")
        connection.send(content: data.data(using: .utf8)!, completion: .contentProcessed { error in
            if let error = error {
                print("DS:Error sending broadcast: \(message) |: \(error.localizedDescription)")
            }
        })
    }
    
    func StartListening(on port: NWEndpoint.Port) {
        let listener = try? NWListener(using: .udp, on: port)
        listener?.newConnectionHandler = { newConnection in
            newConnection.start(queue: .global())
            self.ReceiveBroadcast(on: newConnection)
        }
        listener?.start(queue: .global())
        print("DS:Listening on port \(port)")
    }
    
    private func ReceiveBroadcast(on connection: NWConnection) {
        connection.receiveMessage { data, context, isComplete, error in
            if let error = error {
                print("DS:Error receiving broadcast: \(error.localizedDescription)")
                return
            }

            if let data = data, let message = String(data: data, encoding: .utf8) {
                print("DS:Received broadcast: \(message)")
                
                let segments = message.components(separatedBy: "|")
                let sourceName = segments[0]
                let control = segments[3]
                var aId: String = ""
                switch control {
                case "get_logs":
                    let line = Int(segments[4])!
                    for i in line..<self._logLines.count {
                        self.SendUdp(connection: connection, to: sourceName, message: "log|\(i)|\(self._logLines[i])")
                    }
                    break
                case "set_time_offset":
                    let offsetString = segments[4]
                    if let offset = Int(offsetString) {
                        NeftaPlugin.SetDebugTime(offset: offset)
                    }
                    self.SendUdp(connection: connection, to: sourceName, message: "return|set_time_offset")
                    break
                case "state":
                    self.SendState(connection: connection, to: sourceName)
                    break
                case "create":
                    let placementId = segments[4]
                    for (pId, placement) in NeftaPlugin._instance._placements {
                        if pId == placementId {
                            if placement._type == .Banner {
                                let banner = NBanner(id: pId, position: NBanner.Position.Top)
                                aId = String(banner.hashValue)
                            } else if (placement._type == .Interstitial) {
                                let interstitial = NInterstitial(id: pId)
                                aId = String(interstitial.hashValue)
                            } else if (placement._type == .Rewarded) {
                                let rewarded = NRewarded(id: pId)
                                aId = String(rewarded.hashValue)
                            }
                            break
                        }
                    }
                    self.SendUdp(connection: connection, to: sourceName, message: "return|create|\(aId)")
                    break
                case "partial_bid":
                    do {
                        var bidResponse : String = ""
                        let aId = segments[4]
                        let id = Int(aId)
                        for ad in NeftaPlugin._instance._ads {
                            if ad.hashValue == id {
                                let payload = ad.GetPartialBidRequest()
                                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                                bidResponse = String(data: jsonData, encoding: .utf8)!
                                break
                            }
                        }
                        self.SendUdp(connection: connection, to: sourceName, message: "return|partial_bid|\(aId)|\(bidResponse)")
                    } catch _ as NSError {
                        
                    }
                    break;
                case "bid":
                    aId = segments[4]
                    let id = Int(aId)
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == id {
                            ad.Bid()
                            break
                        }
                    }
                    self.SendUdp(connection: connection, to: sourceName, message: "return|bid|\(aId)")
                    break
                case "custom_load":
                    aId = segments[4]
                    let id = Int(aId)
                    let bidResponse = segments[5]
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == id {
                            ad.LoadWithBidResponse(bidResponse: bidResponse.data(using: .utf8)!)
                            break
                        }
                    }
                    self.SendUdp(connection: connection, to: sourceName, message: "return|custom_load|\(aId)")
                    break;
                case "load":
                    aId = segments[4]
                    let id = Int(aId)
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == id {
                            ad.Load()
                            break
                        }
                    }
                    self.SendUdp(connection: connection, to: sourceName, message: "return|load|\(aId)")
                    break
                case "show":
                    aId = segments[4]
                    let id = Int(aId)
                    for ad in NeftaPlugin._instance._ads {
                        if ad.hashValue == id {
                            DispatchQueue.main.async {
                                ad.Show(viewController: self._viewController)
                            }
                            break
                        }
                    }
                    self.SendUdp(connection: connection, to: sourceName, message: "return|show|\(aId)")
                    break
                case "add_event":
                    do {
                        var name : String?
                        var value: Int64 = 0
                        var customPayload : String?
                        if segments[4] == "progression" {
                            let status = self.ToProgressionStatus(segments[5])
                            let type = self.ToProgressionType(segments[6])
                            let source = self.ToProgressionSource(segments[7])
                            if segments.count > 8 {
                                name = segments[8]
                            }
                            if segments.count > 9 {
                                value = Int64(segments[9])!
                            }
                            if segments.count > 10 {
                                customPayload = segments[10]
                            }
                            NeftaPlugin._instance.Events.AddProgressionEvent(status: status, type: type, source: source, name: name, value: value, customPayload: customPayload)
                        } else if segments[4] == "receive" {
                            let category = self.ToResourceCategory(segments[5])
                            let method = self.ToReceiveMethod(segments[6])
                            if (segments.count > 7) {
                                name = segments[7]
                            }
                            if segments.count > 8 {
                                value = Int64(segments[8])!
                            }
                            if segments.count > 9 {
                                customPayload = segments[9]
                            }
                            NeftaPlugin._instance.Events.AddReceiveEvent(category: category, method: method, name: name, quantity: value, customPayload: customPayload)
                        } else if segments[4] == "spend" {
                            let category = self.ToResourceCategory(segments[5])
                            let method = self.ToSpendMethod(segments[6])
                            if (segments.count > 7) {
                                name = segments[7]
                            }
                            if segments.count > 8 {
                                value = Int64(segments[8])!
                            }
                            if segments.count > 9 {
                                customPayload = segments[9]
                            }
                            NeftaPlugin._instance.Events.AddSpendEvent(category: category, method: method, name: name, quantity: value, customPayload: customPayload)
                        } else if segments[4] == "revenue" {
                            name = segments[5]
                            let price = Decimal(string: segments[6])!
                            let currency = segments[7]
                            if segments.count > 8 {
                                customPayload = segments[8]
                            }
                            NeftaPlugin._instance.Events.AddPurchaseEvent(name: name!, price: price, currency: currency, customPayload: customPayload)
                        }
                        self.SendUdp(connection: connection, to: sourceName, message: "return|add_event")
                    }
                case "add_unity_event":
                    do {
                        let type = Int(segments[4])!
                        let category = Int(segments[5])!
                        let subCategory = Int(segments[6])!
                        let name = segments[7]
                        let value = Int64(segments[8])!
                        var customPayload: String? = nil
                        if segments.count > 9 {
                            customPayload = segments[9]
                        }
                        NeftaPlugin._instance.Record(type: type, category: category, subCategory: subCategory, name: name, value: value, customPayload: customPayload)
                        self.SendUdp(connection: connection, to: sourceName, message: "return|add_unity_event")
                    }
                case "add_external_mediation_request":
                    do {
                        let provider = segments[4]
                        let type = Int(segments[5])!
                        let recommendedAdUnitId = segments[6]
                        let requestedFloor = Float64(segments[7])!
                        let calculatedFloor = Float64(segments[8])!
                        let adUnitId = segments[9]
                        let revenue = Float64(segments[10])!
                        let precision = segments[11]
                        let status = Int(segments[12])!
                        NeftaPlugin.OnExternalMediationRequest(provider, adType: type, recommendedAdUnitId: recommendedAdUnitId, requestedFloorPrice: requestedFloor, calculatedFloorPrice: calculatedFloor, adUnitId: adUnitId, revenue: revenue, precision: precision, status: status)
                        self.SendUdp(connection: connection, to: sourceName, message: "return|add_ad_load")
                    }
                case "get_insights":
                    let insights = segments[4]
                    
                    let insightList = insights.split(separator: ",").map { String($0) }
                    
                    if segments.count > 5 {
                        let callbackIndex = Int(segments[5])!
                        
                        NeftaPlugin._instance.GetBehaviourInsight(insightList, callback: { insights in
                            self.ForwardInsights(index: callbackIndex, insights: insights)
                        })
                    } else {
                        NeftaPlugin._instance.GetBehaviourInsight(insightList)
                    }
                    
                    self.SendUdp(connection: connection, to: sourceName, message: "return|get_insights")
                    break
                case "set_override":
                    let app_id = segments[4]
                    var rest_url: String? = segments[5]
                    if rest_url!.isEmpty && rest_url == "null" {
                        rest_url = nil
                    }
                    
                    NeftaPlugin._instance._info._appId = app_id
                    NeftaPlugin.SetOverride(url: rest_url)
                    NeftaPlugin._instance._placements.removeAll()
                    NeftaPlugin._instance._cachedInitRespose = nil
                    if segments.count > 6 && !segments[6].isEmpty {
                        NeftaPlugin._instance._state._nuid = segments[6]
                    }
                    
                    self.SendUdp(connection: connection, to: sourceName, message: "return|set_override")
                    break
                case "create_file":
                    let path = segments[4]
                    let content = segments[5]
                    
                    var finalPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    do {
                        finalPath = finalPath.appendingPathComponent(path)
                        try content.write(to: finalPath, atomically: false, encoding: .utf8)
                        
                        print("DS:Wrote '\(content)' to \(finalPath.absoluteString)")
                        
                        self.SendUdp(connection: connection, to: sourceName, message: "return|create_file")
                    } catch {
                        print("DS:Error writing to '\(finalPath.absoluteString)': \(error)")
                    }
                    break
                default:
                    print("DS:Unrecognized command: \(control) m: \(message)")
                    break
                }
            }
            self.ReceiveBroadcast(on: connection)
        }
    }
    
    private func StopBroadcastServer() {
        if _timer != nil {
            _timer!.invalidate()
            _timer = nil
        }
        
        if _broadcastConnection != nil {
            _broadcastConnection!.cancel()
            _broadcastConnection = nil
        }
    }
    
    private func SendState(connection: NWConnection, to: String) {
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
            "app_id": NeftaPlugin._instance._info._appId!,
            "rest_url": NeftaPlugin._rtbUrl,
            "nuid": NeftaPlugin._instance._state._nuid,
            "ad_units": adUnits
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            SendUdp(connection: connection, to: to, message: "state|ios|\(NeftaPlugin._instance._info._bundleId)|\(self._version!)|\(_logLines.count)|\(String(data:jsonData, encoding: .utf8)!)")
        } catch _ as NSError {
            
        }
    }
    
    private func ForwardInsights(index: Int, insights: [String: Insight]) {
        if let connection = self._broadcastConnection {
            var message = "return|insights|\(index)|{"
            var isFirst = true
            for (key, insight) in insights {
                if (isFirst) {
                    isFirst = false
                } else {
                    message += ","
                }
                message += "\"\(key)\":{\"f\":\(insight._float),\"i\":\(insight._int),\"s\":\"\(String(describing: insight._string))\"}"
            }
            message += "}"
            self.SendUdp(connection: connection, to: "master", message: message)
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
    
    func GetBroadcastAddress() -> String? {
#if targetEnvironment(simulator)
        return "255.255.255.255"
#else
        var address : String?

        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }

        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        guard let address = address else {
            return nil
        }
        let lastDotRange = address.range(of: ".", options: .backwards)!
        let baseString = address[..<lastDotRange.upperBound]
        return baseString + "255"
#endif
    }
}
