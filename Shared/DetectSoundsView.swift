/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view for visualizing the confidence with which the system is detecting sounds
from the audio input.
*/

import Foundation
import SwiftUI

///  Provides a visualization the app uses when detecting sounds.
struct DetectSoundsView: View {
    /// The runtime state that contains information about the strength of the detected sounds.
    @ObservedObject var state: AppState

    /// The configuration that dictates aspects of sound classification, as well as aspects of the visualization.
    @Binding var config: AppConfiguration

    var body: some View {
        VStack {
            ZStack {
                state.detectionState.currentConfidence > 0.8 ?
                    Color(.red) :
                    Color(.green)

                VStack {
                    Text("Sound Detection Paused").padding()
                    Button(action: { state.restartDetection(config: config) }) {
                        Text("Start")
                    }
                }.opacity(state.soundDetectionIsRunning ? 0.0 : 1.0)
                 .disabled(state.soundDetectionIsRunning)
            }

        }
    }
}
