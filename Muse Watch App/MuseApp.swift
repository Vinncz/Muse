import SwiftUI

@main
struct Muse_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let workoutManagerWrapper = WorkoutManager.instance
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutManagerWrapper)
        }
    }
}
