import Flutter
import UIKit

public class MetroDronePlugin: NSObject, FlutterPlugin {
    let metronome = Metronome()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MetroDronePlugin()

        // Регистрация каналов
        let channel = FlutterMethodChannel(name: "metro_drone", binaryMessenger: registrar.messenger())
        let stateChannel = FlutterEventChannel(name: "metro_drone/state", binaryMessenger: registrar.messenger())
        let tickChannel = FlutterEventChannel(name: "metro_drone/ticks", binaryMessenger: registrar.messenger())

        // Создаём обработчики с одним инстансом метронома
        let stateHandler = MetronomeStateHandler(metronome: instance.metronome)
        let tickHandler = MetronomeTickHandler(metronome: instance.metronome)

         // Устанавливаем делегаты
        instance.metronome.stateDelegate = stateHandler
        instance.metronome.tickDelegate = tickHandler

        // Привязываем обработчики к каналам
        stateChannel.setStreamHandler(stateHandler)
        tickChannel.setStreamHandler(tickHandler)


        registrar.addMethodCallDelegate(instance, channel: channel)
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
            metronome.stateDelegate?.sendState()
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