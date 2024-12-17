import Foundation
import AVFoundation
import SwiftUI

protocol MetronomeDelegate: AnyObject {
    func sendEvent()
}

class Metronome: ObservableObject {
    private var audioEngine: AVAudioEngine
    private var playerNode: AVAudioPlayerNode
    private var regularTickBuffer: AVAudioPCMBuffer?
    private var silenceTickBuffer: AVAudioPCMBuffer?
    private var accentTickBuffer: AVAudioPCMBuffer?
    private var strongAccentTickBuffer: AVAudioPCMBuffer?

    weak var delegate: MetronomeDelegate?
    var bpm: Int = 120 {
        didSet {
            delegate?.sendEvent()
        }
    }

    var isPlaying: Bool = false {
        didSet {
            delegate?.sendEvent()
        }
    }

    var timeSignatureNumerator: Int = 4 {
        didSet {
            if timeSignatureNumerator > tickTypes.count {
                // Добавляем новые элементы (по умолчанию `.regular`)
                tickTypes.append(contentsOf: Array(repeating: .regular, count: timeSignatureNumerator - tickTypes.count))
            } else if timeSignatureNumerator < tickTypes.count {
                // Срезаем лишние элементы
                tickTypes = Array(tickTypes.prefix(timeSignatureNumerator))
            }
            if isPlaying {
                stop()
                start()
            }
        }
    }

    var timeSignatureDenominator: Int = 4 {
        didSet {
            if isPlaying {
                stop()
                start()
            }
            delegate?.sendEvent()
        }
    }

    var currentTick: Int = 0  {
        didSet {
            delegate?.sendEvent()
        }
    }

    var currentSubdivisionTick: Int = 0

    var tickTypes: [TickType] = Array(repeating: .regular, count: 4) {
        didSet {
            delegate?.sendEvent()
        }
    }

    private var nextBeatTime: AVAudioTime?
    private var tapTimes: [Date] = []
    private var tapTimer: Timer?

    @Published var subdivisions: [Subdivision] = [
        Subdivision(name: "Quarter Notes",
                    description: "One quarter note per beat",
                    restPattern: [true],
                    durationPattern: [1.0]),
        Subdivision(name: "Eighth Notes",
                    description: "Two eighth notes",
                    restPattern: [true, true],
                    durationPattern: [0.5, 0.5]),
        Subdivision(name: "Triplet",
                    description: "Three equal triplets",
                    restPattern: [true, true, true],
                    durationPattern: [0.33, 0.33, 0.33]),
        Subdivision(name: "Dotted Eighth and Sixteenth",
                    description: "Dotted eighth and sixteenth",
                    restPattern: [true, true],
                    durationPattern: [0.75, 0.25]),
        Subdivision(name: "Swing",
                    description: "Swing eighth notes (2/3 + 1/3)",
                    restPattern: [true, true],
                    durationPattern: [0.67, 0.33]),
        Subdivision(name: "Rest and Eighth Note",
                    description: "Rest, then eighth note",
                    restPattern: [false, true],
                    durationPattern: [0.5, 0.5])
    ]
    @Published var selectedSubdivision: Subdivision = Subdivision(
        name: "Quarter Notes",
        description: "One quarter note per beat",
        restPattern: [true],
        durationPattern: [1.0]
    )


    enum TickType: CaseIterable {
        case silence
        case regular
        case accent
        case strongAccent
    }

    struct Subdivision: Hashable {
        let name: String               // Имя subdivision (отображается в UI)
        let description: String        // Описание (дополнительно, если нужно)
        let restPattern: [Bool]        // Паттерн пауз (true = звук, false = пауза)
        let durationPattern: [Double]  // Длительности каждой части (в сумме = 1.0)
    }

    init() {
        self.audioEngine = AVAudioEngine()
        self.playerNode = AVAudioPlayerNode()

        do {
            // Используем бандл текущего плагина для загрузки файлов
            let pluginBundle = Bundle(for: MetroDronePlugin.self)

            guard let tickSoundFileURL = pluginBundle.url(forResource: "tick_sound", withExtension: "wav") else {
                fatalError("tick_sound.wav not found in plugin bundle")
            }
            guard let accentTickSoundFileURL = pluginBundle.url(forResource: "accent_sound", withExtension: "wav") else {
                fatalError("accent_sound.wav not found in plugin bundle")
            }
            guard let strongAccentTickSoundFileURL = pluginBundle.url(forResource: "strong_accent_sound", withExtension: "wav") else {
                fatalError("strong_accent_sound.wav not found in plugin bundle")
            }

            self.silenceTickBuffer = try createSilentBuffer(from: tickSoundFileURL)
            self.regularTickBuffer = try createBuffer(from: tickSoundFileURL)
            self.accentTickBuffer = try createBuffer(from: accentTickSoundFileURL)
            self.strongAccentTickBuffer = try createBuffer(from: strongAccentTickSoundFileURL)
        } catch {
            print("Error initializing tick buffer: \(error)")
        }

        setupAudioEngine()
    }


    private func setupAudioEngine() {
        guard let buffer = regularTickBuffer else {
            print("Tick buffer is not initialized.")
            return
        }

        let format = buffer.format
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: format)

        do {
            try audioEngine.start()
            print("Audio engine started successfully.")
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }

    private func createBuffer(from soundFile: URL) throws -> AVAudioPCMBuffer {
        let audioFile = try AVAudioFile(forReading: soundFile)
        let format = audioFile.processingFormat
        let frameCapacity = AVAudioFrameCount(audioFile.length)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else {
            throw NSError(domain: "Metronome", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create buffer"])
        }
        try audioFile.read(into: buffer)
        return buffer
    }

    private func createSilentBuffer(from soundFile: URL) throws -> AVAudioPCMBuffer? {
        let buffer = try createBuffer(from: soundFile)
        guard let channelData = buffer.floatChannelData else { return nil }

        for channel in 0..<Int(buffer.format.channelCount) {
            for frame in 0..<Int(buffer.frameLength) {
                channelData[channel][frame] *= 0.0 // volume
            }
        }

        return buffer
    }

    func setBPM(_ newBPM: Int) {
        DispatchQueue.main.async {
            self.bpm = max(40, min(newBPM, 240))
            print("BPM set to: \(self.bpm)")
            if self.isPlaying {
                self.stop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.start()
                }
            }
        }
    }

    func start() {
        guard !isPlaying else { return }
        isPlaying = true
        currentTick = 0 // Сброс текущего тика
        currentSubdivisionTick = 0
        nextBeatTime = nil // Сбрасываем для точного старта
        playerNode.stop()
        playerNode.play()
        scheduleNextTick()
        print("Metronome started with BPM: \(bpm).")
    }

    func stop() {
        isPlaying = false
        playerNode.stop()
        nextBeatTime = nil
        currentTick = 0
        currentSubdivisionTick = 0
        print("Metronome stopped.")
    }

    private func scheduleNextTick() {
        guard isPlaying else { return }

        let pattern = selectedSubdivision
        let currentIndex = (currentSubdivisionTick) % pattern.restPattern.count

        let sampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
        let duration = (60.0 / Double(bpm)) * (4.0 / Double(timeSignatureDenominator))
        let interval = duration * pattern.durationPattern[currentIndex]
        let frameCount = AVAudioFrameCount((sampleRate * interval).rounded())
        let isAlreadyStarted = nextBeatTime != nil;

        if isAlreadyStarted == false {
            if let lastRenderTime = playerNode.lastRenderTime,
               let playerTime = playerNode.playerTime(forNodeTime: lastRenderTime) {
                nextBeatTime = AVAudioTime(
                    sampleTime: playerTime.sampleTime + AVAudioFramePosition(frameCount),
                    atRate: sampleRate
                )
            } else {
                nextBeatTime = AVAudioTime(sampleTime: AVAudioFramePosition(frameCount), atRate: sampleRate)
            }
        } else {
            nextBeatTime = nextBeatTime?.offset(by: frameCount)
        }

        guard let beatTime = nextBeatTime else { return }

        if pattern.restPattern[currentIndex] && currentTick < tickTypes.count {
            // Звук
            var tickBuffer = regularTickBuffer
            let tickType: TickType = tickTypes[currentTick];

            switch tickType {
            case .silence:
                tickBuffer = silenceTickBuffer
            case .regular:
                tickBuffer = regularTickBuffer
            case .accent:
                tickBuffer = accentTickBuffer
            case .strongAccent:
                tickBuffer = strongAccentTickBuffer
            }

            if selectedSubdivision.durationPattern.count > 1 && tickType != .silence {
                if currentSubdivisionTick >= 1 {
                    tickBuffer = strongAccentTickBuffer;
                }
            }

            playerNode.scheduleBuffer(tickBuffer!, at: beatTime, options: []) { [weak self] in
                guard let self = self else { return }
                self.updateCurrentTick()
            }
        } else {
            // Пауза
            playerNode.scheduleBuffer(silenceTickBuffer!, at: beatTime, options: []) { [weak self] in
                self?.updateCurrentTick()
            }
        }
    }

    private func updateCurrentTick() {
        let pattern = selectedSubdivision
        DispatchQueue.main.async {
            if self.currentSubdivisionTick < pattern.durationPattern.count{
                self.currentSubdivisionTick += 1
            }

            if self.currentSubdivisionTick == pattern.durationPattern.count {
                self.currentSubdivisionTick = 0
                if self.currentTick + 1 == self.timeSignatureNumerator{
                    self.currentTick = 0
                }else {
                    self.currentTick+=1
                }
            }

            print("currentTick: \(self.currentTick) currentSubdivisionTick: $\(self.currentSubdivisionTick)")
            if self.isPlaying {
                self.scheduleNextTick()
            }
        }
    }



    func setTickType(tickIndex: Int) {
        DispatchQueue.main.async {
            guard tickIndex >= 0 && tickIndex < self.tickTypes.count else {
                print("Index out of bounds")
                return
            }

            // Получаем текущий тип
            let currentType = self.tickTypes[tickIndex]

            // Находим следующий тип циклично
            if let currentIndex = TickType.allCases.firstIndex(of: currentType) {
                let nextIndex = (currentIndex + 1) % TickType.allCases.count
                self.tickTypes[tickIndex] = TickType.allCases[nextIndex]
            }
        }
    }

    func tap() {
        if isPlaying {
            stop()
        }

        let now = Date()
        tapTimes.append(now)
        tapTimes = tapTimes.filter { now.timeIntervalSince($0) <= 2.0 }

        if tapTimes.count > 1 {
            let intervals = zip(tapTimes.dropLast(), tapTimes.dropFirst()).map { $1.timeIntervalSince($0) }
            if let averageInterval = intervals.average {
                let calculatedBPM = Int(60.0 / averageInterval)
                setBPM(calculatedBPM)
                print("BPM calculated from tap: \(calculatedBPM)")
            }
        }

        tapTimer?.invalidate()
        tapTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.isPlaying {
                self.start()
                print("Metronome automatically started after tap delay.")
            }
        }

        playTapSound()
    }

    private func playTapSound() {
        guard let buffer = regularTickBuffer else {
            print("Tick buffer is not initialized.")
            return
        }
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        playerNode.play()
        print("Tap sound played.")
    }
}

private extension Array where Element == TimeInterval {
    var average: TimeInterval? {
        guard !isEmpty else { return nil }
        return reduce(0, +) / Double(count)
    }
}

private extension AVAudioTime {
    func offset(by frames: AVAudioFrameCount) -> AVAudioTime? {
        return AVAudioTime(sampleTime: self.sampleTime + AVAudioFramePosition(frames), atRate: self.sampleRate)
    }
}