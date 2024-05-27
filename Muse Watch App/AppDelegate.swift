//
//  AppDelegate.swift
//  Muse Watch App
//
//  Created by Vin on 26/05/24.
//

import Foundation
import HealthKit
import SwiftUI
import WatchKit

class AppDelegate : NSObject, WKApplicationDelegate {
    
    func handle ( _ workoutConfiguration: HKWorkoutConfiguration ) {
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
