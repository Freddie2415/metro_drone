import Flutter

class MetronomeStateHandler: NSObject, FlutterStreamHandler, MetronomeStateDelegate {
    private var eventSink: FlutterEventSink?
    private let metronome: Metronome

    init(metronome: Metronome) {
        self.metronome = metronome
        super.init()
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        sendState() // Отправляем начальное состояние
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    func sendState() {
        guard let eventSink = eventSink else { return }
        let state: [String: Any] = [
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
            "tickTypes": metronome.tickTypes.map { $0.rawValue }
        ]
        eventSink(state)
    }
}
