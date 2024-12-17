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
                metronome.bpm = bpm
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
            "timeSignatureDenominator": metronome.timeSignatureDenominator
        ]

        print("Sending event: \(event)") // Вывод данных в консоль
        eventSink(event)
    }
}