import Foundation
import Speech
import AVFoundation

class DictationService: NSObject, ObservableObject {
    // Speech recognition components
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    // Published properties for UI binding
    @Published var transcribedText = ""
    @Published var isListening = false
    @Published var audioLevel: Float = 0.0
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    override init() {
        super.init()
        checkAuthorization()
    }

    // MARK: - Authorization

    func checkAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
            }
        }
    }

    // MARK: - Dictation Control

    func startDictation() {
        // Stop any existing session
        if audioEngine.isRunning {
            stopDictation()
            return
        }

        // Check authorization
        guard authorizationStatus == .authorized else {
            errorMessage = "Speech recognition not authorized"
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create recognition request"
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        // Get audio input node
        let inputNode = audioEngine.inputNode

        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
            }

            if error != nil || (result?.isFinal ?? false) {
                self.stopDictation()
            }
        }

        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)

            // Calculate audio level for volume meter
            let channelData = buffer.floatChannelData?[0]
            let channelDataCount = Int(buffer.frameLength)

            if let channelData = channelData {
                var sum: Float = 0
                for i in 0..<channelDataCount {
                    sum += abs(channelData[i])
                }
                let average = sum / Float(channelDataCount)

                DispatchQueue.main.async {
                    self?.audioLevel = average
                }
            }
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            DispatchQueue.main.async {
                self.isListening = true
                self.transcribedText = ""
                self.errorMessage = nil
            }
        } catch {
            errorMessage = "Audio engine failed to start: \(error.localizedDescription)"
        }
    }

    func stopDictation() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        DispatchQueue.main.async {
            self.isListening = false
            self.audioLevel = 0.0
        }
    }

    func resetTranscription() {
        transcribedText = ""
    }

    // MARK: - Cleanup

    deinit {
        if audioEngine.isRunning {
            stopDictation()
        }
    }
}
