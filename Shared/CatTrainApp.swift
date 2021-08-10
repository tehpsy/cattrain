import SwiftUI
import SoundAnalysis
import Combine

@main
struct CatTrainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

typealias SoundIdentifier = String

struct AppConfiguration {
    let inferenceWindowSize = Double(1.5)
    let overlapFactor = Double(0.9)
    let monitoredSound: SoundIdentifier = "cat_meow"
}

class AppState: ObservableObject {
    private var detectionCancellable: AnyCancellable? = nil
    private let appConfig = AppConfiguration()
    private let systemAudioClassifier = SystemAudioClassifier()

    @Published var detectionState: DetectionState = DetectionState.default
    @Published var soundDetectionIsRunning: Bool = false

    init() {
        restartDetection(config: appConfig)
    }

    func restartDetection(config: AppConfiguration) {
        systemAudioClassifier.stopSoundClassification()

        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()

        detectionCancellable =
          classificationSubject
          .receive(on: DispatchQueue.main)
          .sink(
            receiveCompletion: { _ in
                self.soundDetectionIsRunning = false
            },
            receiveValue: { result in
                let confidence = result.classification(forIdentifier: self.appConfig.monitoredSound)?.confidence ?? 0
                self.detectionState = DetectionState(advancedFrom: self.detectionState, currentConfidence: confidence)
            })

        soundDetectionIsRunning = true
        systemAudioClassifier.startSoundClassification(
          subject: classificationSubject,
          inferenceWindowSize: config.inferenceWindowSize,
          overlapFactor: config.overlapFactor
        )
    }
}
