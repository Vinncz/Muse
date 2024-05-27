import SwiftUI
import SwiftData

@main
struct MuseApp: App {
    private let workoutManager = WorkoutManager.instance
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            Music.self,
            Attempt.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer( for: schema, configurations: [modelConfiguration] )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(workoutManager)
                .tint(.pink)
        }
        .modelContainer(sharedModelContainer)
    }
}
