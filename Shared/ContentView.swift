import SwiftUI

struct ContentView: View {
    @State var appConfig = AppConfiguration()
    @StateObject var appState = AppState()

    var body: some View {
        DetectSoundsView(
            state: appState,
            config: $appConfig
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
