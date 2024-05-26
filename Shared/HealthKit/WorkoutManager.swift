// Copyright © 2023 Apple Inc.
// Copyright © 2024 Kevin Gunawan
// This file partly contains copyrighted (MIT Licensed) works of Apple Inc.

import Foundation
import HealthKit
import Observation
import os

/* WorkoutManager's singleton helper */
extension WorkoutManager {
    private static let instance = WorkoutManager()
    static func getInstance () -> WorkoutManager { return instance }
}

@MainActor @Observable class WorkoutManager: NSObject {

    /*
     Every initialization of WorkoutManager kicks off a Task; which consumes an asynchronous stream. 
    
     For the lack of a better term, a "Task" is like a to-do item for a program.
     It represents a piece-of-code that needs to be done, which might take some time to complete, 
         because it involves waiting for something else to happen (e.g. waiting for data returned from server).
    
     Similarly, picture a "Stream" to be like an airport's conveyor belt.
     It "streams" those luggages (data) to you, as the workers put those luggages onto the stream (as the data is being created).
     
     The important thing about Tasks is that they can be asynchronous, meaning they can begin at some point; 
         yet stop halfway and let [others] finish first; Because, they might wait for those [other jobs] to make an opening for itself to continue.
    
     Using await logic, the next value in the stream will not and cannot begin processing until "await consumeSessionStateChange(value)" returns 
         and the loop enters the next iteration, which ensure that no data gets overlooked.
     */
    private override init ( ) {
        super.init()
        Task {
            for await value in asynStreamTuple.stream {
                await handleTheChangeOfStateForASession(value)
            }
        }
    }
    
    
    /** The function which handles "what to do" when the state-of-the-workout did change */
    private func handleTheChangeOfStateForASession ( _ change: SessionSateChange ) async {
        self.sessionState = change.newState
        
        /* If [Watchful Muse] is the one who initiates the change of state */
        #if os(watchOS)
            await prepareAndSendElapsedTime( change.effectiveDate )
    
            guard change.newState == .stopped, let builder else { return }
            await handleWorkoutStoppage( change.effectiveDate )
        #endif
    }
    
    
    /* Constants which are supplied by either AppValueProvider or AppConfig */
    let healthStore        = AppValueProvider.healthStore    
    let typesToShare : Set = AppConfig.healthKitShareTypes
    let typesToRead  : Set = AppConfig.healthKitReadTypes
 
    
    /* The workout session's live-states, which the UI observes */
    var elapsedTimeInterval : TimeInterval = 0
    var sessionState        : HKWorkoutSessionState = .notStarted
    var workoutValues       = MonitoredWorkoutValue()
    
    
    /* Mutating variables which are used by WorkoutManager for various purposes */
    var workout         : HKWorkout?
    var session         : HKWorkoutSession?
    let asynStreamTuple = AsyncStream.makeStream ( /* Creates an async stream of SessionStateChange object. Unlike first-in-first-out, the policy of `.bufferingNewest(limit)` disregards any old value, and only keep those the n-most recent value. */
        of: SessionSateChange.self, 
        bufferingPolicy: .bufferingNewest(1)
    )
    #if os(watchOS)
        var builder     : HKLiveWorkoutBuilder?    /* The live-workout builder that is only available on watchOS. */ 
    #else
        var contextDate : Date?                    /* A date for synchronizing the elapsed time between iOS and watchOS. */
    #endif
    
}

@Observable class MonitoredWorkoutValue {
    var heartRate          : Double = 0.0
    var activeEnergyBurned : Double = 0.0
    
    func reset () -> Void {
        self.heartRate          = 0
        self.activeEnergyBurned = 0
    }
}

struct WorkoutElapsedTime : Codable {
    var timeInterval : TimeInterval
    var date         : Date
}

struct SessionSateChange {
    let newState      : HKWorkoutSessionState
    let effectiveDate : Date
}


/* 
 MARK: - Learning Corner
 
 ## Non-isolated
 The term "non-isolated" means that other functions besides this one can access and modify the same data at the same time. 
 It's like saying "It's okay if other functions touch this data while I'm using it."
 
 ## Yield
 The term "yield" in context of "stream", means "I'm putting these data I'm holding onto the conveyor belt (stream), and they can take it away from here."
*/
