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

    let _connection: NWConnection
    let _serial: String
    
    @objc init(ip: String, serial: String) {
        let endpoint = NWEndpoint.Host(ip)
        let port = NWEndpoint.Port(rawValue: 12012)!
        
        _connection = NWConnection(host: endpoint, port: port, using: .tcp)
        _serial = serial
        
        super.init()
        
        _connection.start(queue: DispatchQueue(label: "DS", attributes: .concurrent))
        
        _connection.stateUpdateHandler = { state in
            switch state {
            case .ready:
                self.send(type: "log", message: "Debug server connected")
                print("DS:Connection established")
                self.startReceiving()
            case .failed(let error):
                print("DS:Connection failed: \(error)")
            case .cancelled:
                print("DS:Connection cancelled")
            default:
                break
            }
        }
    }
    
    func startReceiving() {
        _connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
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
                case "set_time":
                    let doubleAsString = String(message[message.index(after: controlEnd!)...])
                    if let time = Double(doubleAsString) {
                        NeftaPlugin.SetDebugTime(time: time)
                    }
                    self.send(type: "return", message: "set_time")
                    break
                case "ad_units":
                    var adUnits = [[String: Any]]()
                    for placement in NeftaPlugin._instance._publisher._placements {
                        let adUnit : [String: Any] = [
                            "id": placement.key,
                            "type": placement.value._type.description
                        ]
                        adUnits.append(adUnit)
                    }
                    let payload: [String: Any] = [
                        "ad_units": adUnits
                    ]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                        self.send(type: "return ad_units", message: String(data: jsonData, encoding: .utf8)!)
                    } catch _ as NSError {
                        
                    }
                    break
                case "partial_bid":
                    do {
                        let pId = String(message[message.index(after: controlEnd!)...])
                        let payload = NeftaPlugin._instance.GetPartialBidRequest(id: pId)!
                        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                        self.send(type: "return partial_bid", message: String(data: jsonData, encoding: .utf8)!)
                    } catch _ as NSError {
                        
                    }
                    break;
                case "bid":
                    let pId = String(message[message.index(after: controlEnd!)...])
                    NeftaPlugin._instance.Bid(id: pId)
                    break
                case "custom_load":
                    let pIdStart = message.index(after: controlEnd!)
                    let temp = String(message[pIdStart...])
                    let pIdEnd = temp.firstIndex(of: " ")!
                    let pId = String(temp[...temp.index(before:pIdEnd)])
                    let bidResponse = String(temp[temp.index(after:pIdEnd)...]).data(using: .utf8)!
                    NeftaPlugin._instance.LoadWithBidResponse(id: pId, bidResponse: bidResponse)
                    self.send(type: "return", message: "custom_load")
                    break;
                case "load":
                    let pId = String(message[message.index(after: controlEnd!)...])
                    NeftaPlugin._instance.Load(id: pId)
                    self.send(type: "return", message: "load")
                    break
                case "show":
                    let pId = String(message[message.index(after: controlEnd!)...])
                    NeftaPlugin._instance.Show(id: pId)
                    self.send(type: "return", message: "show")
                    break
                default:
                    print("DS:Unrecognized command: \(control)")
                    break
                }
            }
            self.startReceiving()
        }
    }
    
    @objc func send(type: String, message: String) {
        let payload = "\(_serial) \(type) \(message)`"
        _connection.send(content: payload.data(using: .utf8), completion: .contentProcessed { error in
        })
    }
}
