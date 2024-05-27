import os
import HealthKit
import SwiftUI
import WatchKit

class MuseAppDelegate: NSObject, WKApplicationDelegate {
    
    func handle ( _ workoutConfiguration: HKWorkoutConfiguration ) {
        debug("Watch has been woken up. Begin trying to start workout.")
        Task {
            do {
                WorkoutManager.instance.resetWorkout()
                try await WorkoutManager.instance.startWorkout(workoutConfiguration: workoutConfiguration)
                debug("Successfully started workout")
            } catch {
                debug("Failed started workout")
            }
        }
    }
    
}


