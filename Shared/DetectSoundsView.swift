import Foundation
import SwiftUI

struct DetectSoundsView: View {
    @ObservedObject var state: AppState
    let config: AppConfiguration

    var body: some View {
        VStack {
            ZStack {
                Color(.black)

                Self.image(given: state.detectionState.currentConfidence)

                    .clipped()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Toggle("TRAIN IT!!", isOn: $state.playAlert)
                        .frame(width: 200)
                        .offset(x: 0, y: -10)
                }

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

    private static func image(given confidence: Double) -> some View {
        return (
            confidence > 0.8 ?
                Image("open") :
                Image("shut")
        )
            .resizable()
            .scaledToFill()
    }
}

struct DetectSoundsView_Previews: PreviewProvider {
    static var previews: some View {
        DetectSoundsView(
            state: AppState(),
            config: AppConfiguration()
        )
    }
}
