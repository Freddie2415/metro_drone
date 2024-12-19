import Flutter

class MetronomeTickHandler: NSObject, FlutterStreamHandler, MetronomeTickDelegate {
    private var eventSink: FlutterEventSink?
    private let metronome: Metronome

    init(metronome: Metronome) {
        self.metronome = metronome
        super.init()
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func sendTick() {
        guard let eventSink = eventSink else { return }
        let tick: [String: Int] = [
            "currentTick": metronome.currentTick,
            "currentSubdivisionTick": metronome.currentSubdivisionTick
        ]

        eventSink(tick)
    }
}
