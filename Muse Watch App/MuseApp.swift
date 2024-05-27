import SwiftUI
import WatchKit

@main
struct Muse_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(MuseAppDelegate.self) var appDelegate
    private let workoutManagerWrapper = WorkoutManager.instance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutManagerWrapper)
                .onAppear() {
                    debug("delegate: \(appDelegate)")
                }
        }
    }
}
