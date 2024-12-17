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
    
    var subdivision: Subdivision = Subdivision(
        name: "Quarter Notes",
        description: "One quarter note per beat",
        restPattern: [true],
        durationPattern: [1.0]
    ) {
        didSet {
            delegate?.sendEvent()
        }
    }
    
    private var nextBeatTime: AVAudioTime?
    private var tapTimes: [Date] = []
    private var tapTimer: Timer?
    
    enum TickType: String, CaseIterable {
        case silence = "silence"
        case regular = "regular"
        case accent = "accent"
        case strongAccent = "strongAccent"
        
        // Преобразование в строку (toString)
        func toString() -> String {
            return self.rawValue
        }
        
        // Преобразование из строки в enum (fromString)
        static func fromString(_ value: String) -> TickType? {
            return TickType(rawValue: value)
        }
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
    
    deinit {
        dispose()
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
            self.bpm = max(20, min(newBPM, 400))
            print("BPM set to: \(self.bpm)")
            if self.isPlaying {
                self.stop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.start()
                }
            }
        }
    }
    
    func setSubdivision(_ name: String, _ description: String, _ restPattern: [Bool], _ durationPattern: [Double]) {
        subdivision = Subdivision(
            name: name,
            description: description,
            restPattern: restPattern,
            durationPattern: durationPattern
        )
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
        currentTick = 0 // Сбрасываем текущий тик для визуализации
        currentSubdivisionTick = 0
        print("Metronome stopped.")
    }
    
    func dispose() {
        audioEngine.stop()
        playerNode.stop()
        print("Audio engine disposed.")
    }
    
    private func scheduleNextTick() {
        guard isPlaying else { return }
        
        let pattern = subdivision
        let currentIndex = (currentSubdivisionTick) % pattern.restPattern.count
        print("CURRENT INDEX: $\(currentIndex)")
        
        let sampleRate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
        let duration = (60.0 / Double(bpm))
        let interval = duration * pattern.durationPattern[currentIndex]
        let frameCount = AVAudioFrameCount((sampleRate * interval).rounded())
        let isAlreadyStarted = nextBeatTime != nil;
        
        if nextBeatTime == nil {
            nextBeatTime = AVAudioTime(sampleTime: 0, atRate: sampleRate) // Начало с текущего времени
        } else {
            nextBeatTime = nextBeatTime?.offset(by: frameCount)
        }
        
        guard let beatTime = nextBeatTime else { return }
        
        if pattern.restPattern[currentIndex] && currentTick < tickTypes.count {
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
            
            if subdivision.durationPattern.count > 1 && tickType != .silence {
                if currentSubdivisionTick >= 1 {
                    tickBuffer = strongAccentTickBuffer;
                }
            }
            
            playerNode.scheduleBuffer(tickBuffer!, at: beatTime, options: .interrupts) { [weak self] in
                self?.updateCurrentTick()
            }
        } else {
            playerNode.scheduleBuffer(silenceTickBuffer!, at: beatTime, options: .interrupts) { [weak self] in
                self?.updateCurrentTick()
            }
        }
        
        print("Schedule Next Tick | currentTick:\(currentTick) currentSubdivisionTick:\(currentSubdivisionTick)")
    }
    
    private func updateCurrentTick() {
        if !self.isPlaying {
            return
        }
        print("TICK PLAYED | currentTick: \(self.currentTick) currentSubdivisionTick: $\(self.currentSubdivisionTick)")
        let pattern = subdivision
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
            
            print("TICK UPDATED | currentTick: \(self.currentTick) currentSubdivisionTick: $\(self.currentSubdivisionTick)")
            self.scheduleNextTick()
        }
    }
    
    func setNextTickType(tickIndex: Int) {
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
    
    func setTickType(tickIndex: Int, tickType: TickType) {
        guard tickIndex >= 0 && tickIndex < self.tickTypes.count else {
            print("Index out of bounds")
            return
        }
        
        self.tickTypes[tickIndex] = tickType
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
