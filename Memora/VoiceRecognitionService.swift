import AVFoundation
import Combine
import Speech

@MainActor
final class VoiceRecognitionService: ObservableObject {
    @Published var isRecording = false
    @Published var transcript = ""
    @Published var authorizationGranted = false
    @Published var errorMessage: String?

    private let speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    init(locale: Locale = Locale(identifier: "zh-CN")) {
        if let recognizer = SFSpeechRecognizer(locale: locale) {
            self.speechRecognizer = recognizer
        } else {
            self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        }
    }

    func requestAuthorization() async -> Bool {
        let microphoneAuthorized = await requestMicrophoneAuthorization()
        let speechAuthorized = await requestSpeechAuthorization()

        authorizationGranted = microphoneAuthorized && speechAuthorized
        if !authorizationGranted {
            errorMessage = "Microphone or speech recognition permission not granted."
        }
        return authorizationGranted
    }

    func startRecording() throws {
        guard authorizationGranted else {
            throw VoiceError.notAuthorized
        }

        guard let speechRecognizer, speechRecognizer.isAvailable else {
            throw VoiceError.recognizerUnavailable
        }

        stopRecording()
        transcript = ""
        errorMessage = nil

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        recognitionRequest = request

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                self.transcript = result.bestTranscription.formattedString
                if result.isFinal {
                    self.finishRecording(cancelRecognitionTask: false)
                }
            }

            if let error {
                self.errorMessage = error.localizedDescription
                self.finishRecording(cancelRecognitionTask: true)
            }
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            finishRecording(cancelRecognitionTask: true)
            throw VoiceError.audioEngineFailed(error)
        }
    }

    func stopRecording() {
        finishRecording(cancelRecognitionTask: true)
    }

    private func finishRecording(cancelRecognitionTask: Bool) {
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil

        if cancelRecognitionTask {
            recognitionTask?.cancel()
        }
        recognitionTask = nil
        isRecording = false
    }

    private func requestMicrophoneAuthorization() async -> Bool {
        #if os(iOS)
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        #elseif os(macOS)
        return await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
        #else
        return true
        #endif
    }

    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    enum VoiceError: LocalizedError {
        case notAuthorized
        case recognizerUnavailable
        case audioEngineFailed(Error)

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Voice permissions are not authorized."
            case .recognizerUnavailable:
                return "Speech recognizer is unavailable right now."
            case .audioEngineFailed(let error):
                return "Failed to start recording: \(error.localizedDescription)"
            }
        }
    }
}
