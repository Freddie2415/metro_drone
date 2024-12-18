import Flutter
import UIKit

public class MetroDronePlugin: NSObject, FlutterPlugin {
    let metronome = Metronome()
    private var eventSink: FlutterEventSink?
    
    override init() {
        super.init()
        metronome.delegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "metro_drone", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "metro_drone/events", binaryMessenger: registrar.messenger())
        
        let instance = MetroDronePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            if  let args = call.arguments as? [String: Any],
                let bpm = args["bpm"] as? Int,
                let numerator = args["timeSignatureNumerator"] as? Int,
                let denominator = args["timeSignatureDenominator"] as? Int,
                let subdivision =  args["subdivision"] as? [String: Any],
                let name = subdivision["name"] as? String,
                let description = subdivision["description"] as? String,
                let restPattern = subdivision["restPattern"] as? [Bool],
                let durationPattern = subdivision["durationPattern"] as? [Double],
                let tickTypesString = args["tickTypes"] as? [String] {
                
                metronome.setBPM(bpm)
                metronome.timeSignatureNumerator = numerator
                metronome.timeSignatureDenominator = denominator
                metronome.setSubdivision(
                    name,
                    description,
                    restPattern,
                    durationPattern
                )
                metronome.tickTypes = tickTypesString.compactMap { Metronome.TickType.fromString($0) };
                
                result("Metronome initialized")
            }else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "initialize value missing", details: nil))
            }
        case "getCurrentState":
            self.sendEvent()
        case "start":
            metronome.start()
            result("Metronome started")
        case "stop":
            metronome.stop()
            result("Metronome stopped")
        case "tap":
            metronome.tap()
            result("Metronome tap")
        case "setBpm":
            if let args = call.arguments as? Int,
               let bpm = args as? Int {
                metronome.setBPM(bpm)
                result("BPM set to \(bpm)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "BPM value missing", details: nil))
            }
        case "setTimeSignature":
            if let args = call.arguments as? [String: Int],
               let numerator = args["numerator"] as? Int,
               let denominator = args["denominator"] as? Int {
                metronome.timeSignatureNumerator = numerator
                metronome.timeSignatureDenominator = denominator
                result("TimeSignatureSet \(numerator)\\\(denominator)")
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "TimeSignatureSet values missing", details: nil))
            }
        case "setSubdivision":
            if let args = call.arguments as? [String: Any],
               let name = args["name"] as? String,
               let description = args["description"] as? String,
               let restPattern = args["restPattern"] as? [Bool],
               let durationPattern = args["durationPattern"] as? [Double] {
                metronome.setSubdivision(
                    name,
                    description,
                    restPattern,
                    durationPattern
                )
            }else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "setSubdivision values missing", details: nil))
            }
        case "setNextTickType":
            if let args = call.arguments as? Int,
               let tickIndex = args as? Int {
                metronome.setNextTickType(tickIndex: tickIndex)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "setNextTickType values missing", details: nil))
            }
        case "setTickType":
            if let args = call.arguments as? [String: Any],
               let tickIndex = args as? Int,
               let tickTypeString = args as? String {
                let tickType = Metronome.TickType.fromString(tickTypeString) ?? .regular
                metronome.setTickType(tickIndex: tickIndex, tickType: tickType)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "setTickType values missing", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

extension MetroDronePlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        sendEvent()
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}

extension MetroDronePlugin: MetronomeDelegate {
    func sendEvent() {
        guard let eventSink = eventSink else {
            print("EventSink is nil")
            return
        }
        
        let event: [String: Any] = [
            "isPlaying": metronome.isPlaying,
            "bpm": metronome.bpm,
            "currentTick": metronome.currentTick,
            "currentSubdivisionTick": metronome.currentSubdivisionTick,
            "timeSignatureNumerator": metronome.timeSignatureNumerator,
            "timeSignatureDenominator": metronome.timeSignatureDenominator,
            "subdivision": [
                "name": metronome.subdivision.name,
                "description": metronome.subdivision.description,
                "restPattern": metronome.subdivision.restPattern,
                "durationPattern": metronome.subdivision.durationPattern,
            ],
            "tickTypes": metronome.tickTypes.map { $0.rawValue },
        ]
        
        print("Sending event: \(event)") // Вывод данных в консоль
        eventSink(event)
    }
}
