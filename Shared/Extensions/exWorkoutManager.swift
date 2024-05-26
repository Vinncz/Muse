// Copyright © 2023 Apple Inc.
// Copyright © 2024 Kevin Gunawan
// This file partly contains copyrighted (MIT Licensed) works of Apple Inc.

import HealthKit

/* WorkoutManager's workout session management. The following codes are valid on both iOS and watchOS. For platform-specific functions, head over to `WorkoutManager_iOS.swift` or `WorkoutManager_watchOS.swift. */
extension WorkoutManager {
    
    /** Convenience function to reset all variables */
    func resetWorkout ( ) {
        workout = nil
        session = nil
        workoutValues.reset()
        sessionState = .notStarted
        #if os(watchOS)
            builder = nil
        #endif
    }
    
    /** The function which made communication between mirrored-workout-sessions possible */
    func sendData ( _ data: Data ) async {
        do {
            try await session?.sendToRemoteWorkoutSession(data: data)
        } catch {
            debug("Failed to send data: \(error)")
        }
    }
    
}

/* WorkoutManager's workout statistics */
extension WorkoutManager {
    
    /** The function which updates the `workoutValue` variable. Do remember that `workoutValue` is the variable which is observed by a number of views. */
    func updateForStatistics ( _ statistics: HKStatistics ) {
        switch statistics.quantityType {
            case HKQuantityType.quantityType( forIdentifier: .heartRate ):
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                workoutValues.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                
            case HKQuantityType.quantityType( forIdentifier: .activeEnergyBurned ):
                let energyUnit = HKUnit.kilocalorie()
                workoutValues.activeEnergyBurned = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
                
            default:
                return
                
        }
    }
}

/* 
 Conforming WorkoutManager to be a confirmed delegator for HKWorkoutSession, should it be run on iOS 
 https://developer.apple.com/documentation/healthkit/hkworkoutsessiondelegate
 */
extension WorkoutManager: HKWorkoutSessionDelegate {
    
    /* Inherited from `HKWorkoutSessionDelegate.workoutSession`. Refrain from renaming or changing the signature of the following. */
    /** Tells the [WorkoutManager] that the session’s state has changed. */
    nonisolated func workoutSession ( _ workoutSession : HKWorkoutSession, didChangeTo newState : HKWorkoutSessionState, from oldState : HKWorkoutSessionState, date stateDidChangeOn : Date ) {
        debug("Session state changed from \(oldState.rawValue) to \newState.rawValue)")
        
        let sessionSateChange = SessionSateChange( newState: newState, effectiveDate: stateDidChangeOn )
        asynStreamTuple.continuation.yield(sessionSateChange)
    }
        
    /* Inherited from `HKWorkoutSessionDelegate.workoutSession`. Refrain from renaming or changing the signature of the following. */
    /** Tells the [WorkoutManager] that the session’s state has failed with an error. */
    nonisolated func workoutSession ( _ workoutSession: HKWorkoutSession, didFailWithError error: Error ) { debug("\(#function): \(error)") }
    
    /** Inherited from `HKWorkoutSessionDelegate.workoutSession`. Refrain from renaming or changing the signature of the following. */
    /* Note: HealthKit calls this method when it determines that the mirrored workout session is invalid. */
    nonisolated func workoutSession ( _ workoutSession: HKWorkoutSession, didDisconnectFromRemoteDeviceWithError error: Error? ) { debug("\(#function): \(String(describing: error))") }
    
    /*
     In iOS, the sample app can go into the background and become suspended.
     When suspended, HealthKit gathers the data coming from the remote session.
     When the app resumes, HealthKit sends an array containing all the data objects it has accumulated to this delegate method.
     The data objects in the array appear in the order that the local system received them.
     
     On watchOS, the workout session keeps the app running even if it is in the background; however, the system can
     temporarily suspend the app — for example, if the app uses an excessive amount of CPU in the background.
     While suspended, HealthKit caches the incoming data objects and delivers an array of data objects when the app resumes, just like in the iOS app.
     */
    /** Passes data from the remote workout-session to the [WorkoutManager] */
    nonisolated func workoutSession ( _ workoutSession: HKWorkoutSession, didReceiveDataFromRemoteWorkoutSession data: [Data] ) {
        debug("\(#function): \(data.debugDescription)")
        
        Task { @MainActor in
            do {
                for anElement in data {
                    try handleReceivedData(anElement)
                }
            } catch {
                debug("Failed to handle received data: \(error))")
            }
        }
    }
}
