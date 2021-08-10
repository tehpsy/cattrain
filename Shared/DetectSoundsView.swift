import Foundation
import SwiftUI

struct DetectSoundsView: View {
    @ObservedObject var state: AppState
    @Binding var config: AppConfiguration

    var body: some View {
        VStack {
            ZStack {
                state.detectionState.currentConfidence > 0.8 ?
                    Color(.green) :
                    Color(.red)

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
