//
//  CatTrainApp.swift
//  Shared
//
//  Created by James Baxter on 10/08/2021.
//

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

struct AppConfiguration {
    /// Indicates the amount of audio, in seconds, that informs a prediction.
    let inferenceWindowSize = Double(1.5)

    /// The amount of overlap between consecutive analysis windows.
    ///
    /// The system performs sound classification on a window-by-window basis. The system divides an
    /// audio stream into windows, and assigns labels and confidence values. This value determines how
    /// much two consecutive windows overlap. For example, 0.9 means that each window shares 90% of
    /// the audio that the previous window uses.
    let overlapFactor = Double(0.9)

    /// A list of sounds to identify from system audio input.
    let monitoredSound: SoundIdentifier = "cat_meow"
}

typealias SoundIdentifier = String

class AppState: ObservableObject {
    private var detectionCancellable: AnyCancellable? = nil
    private let appConfig = AppConfiguration()

    @Published var detectionState: DetectionState = DetectionState(
        presenceThreshold: 0.5,
        absenceThreshold: 0.3,
        presenceMeasurementsToStartDetection: 2,
        absenceMeasurementsToEndDetection: 30
    )
    @Published var soundDetectionIsRunning: Bool = false

    init() {
        restartDetection(config: appConfig)
    }

    func restartDetection(config: AppConfiguration) {
        SystemAudioClassifier.singleton.stopSoundClassification()

        let classificationSubject = PassthroughSubject<SNClassificationResult, Error>()

        detectionCancellable =
          classificationSubject
          .receive(on: DispatchQueue.main)
          .sink(
            receiveCompletion: { _ in
                self.soundDetectionIsRunning = false
            },
            receiveValue: { result in
                self.detectionState = self.detectionState.advance(given: result, for: self.appConfig.monitoredSound)
            })

        soundDetectionIsRunning = true
        SystemAudioClassifier.singleton.startSoundClassification(
          subject: classificationSubject,
          inferenceWindowSize: config.inferenceWindowSize,
          overlapFactor: config.overlapFactor
        )
    }
}

extension DetectionState {
    func advance(
        given result: SNClassificationResult,
        for sound: SoundIdentifier
    ) -> DetectionState {
        let confidence = result.classification(forIdentifier: sound)?.confidence ?? 0
        return DetectionState(advancedFrom: self, currentConfidence: confidence)
    }
}
