// Copyright © 2023 Apple Inc.
// Copyright © 2024 Kevin Gunawan
// This file partly contains copyrighted (MIT Licensed) works of Apple Inc.

import Foundation
import HealthKit
import os

/* WorkoutManager's workout session management on watchOS */
extension WorkoutManager {
    
    /** Requests permission to access Health data for [Watchful Muse] */
    func requestAuthorization ( ) {
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            } catch {
                debug("Failed to request authorization: \(error)")
            }
        }
    }
    
    /** Enables [Watchful Muse] to start the workout, there and then */
    func startWorkout ( workoutConfiguration: HKWorkoutConfiguration ) async throws {
        session = try HKWorkoutSession( healthStore: healthStore, configuration: workoutConfiguration )
        builder = session?.associatedWorkoutBuilder()
        
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource( healthStore: healthStore, workoutConfiguration: workoutConfiguration )
        
        /* Signals the [Muse on iOS] that a workout has been started on [Watchful Muse] */
        try await session?.startMirroringToCompanionDevice()
        
        /* Commences the workout session activity, on watch */
        let startDate = Date()
        session?.startActivity(with: startDate)
        
        try await builder?.beginCollection(at: startDate)
    }
    
    /** The function which handles the data sent from [Muse on iOS] */
    func handleReceivedData ( _ data: Data ) throws {
        guard let decodedQuantity = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQuantity.self, from: data) else {
            return
        }
//        water += decodedQuantity.doubleValue(for: HKUnit.fluidOunceUS())
//
//        let sampleDate = Date()
//        Task {
//            let waterSample = [HKQuantitySample(type: HKQuantityType(.dietaryWater), quantity: decodedQuantity, start: sampleDate, end: sampleDate)]
//            try await builder?.addSamples(waterSample)
//        }
    }
    
    /** Sends an elapsed-time object, encoded using JSON, to the mirrored sessions. Elapsed-time objects are needed to ensure consistency of the data between devices */
    func prepareAndSendElapsedTime ( _ elapsedTime: Date ) async {
        #if os(watchOS)
            let elapsedTimeInterval = session?.associatedWorkoutBuilder().elapsedTime( at: elapsedTime ) ?? 0
            let elapsedTime         = WorkoutElapsedTime( timeInterval: elapsedTimeInterval, date: elapsedTime )
            if let elapsedTimeData  = try? JSONEncoder().encode(elapsedTime) {
                await sendData(elapsedTimeData)
            }
        #endif
    }
    
    /** The function which handles "what to do" where instead of [Muse on iOS], [Watchful Muse] is the one who ends the workout */
    func handleWorkoutStoppage ( _ elapsedTime: Date ) async {
        #if os(watchOS)
            let finishedWorkout: HKWorkout?
            do {
                try await builder?.endCollection(at: elapsedTime)
                finishedWorkout = try await builder?.finishWorkout()
                session?.end()
            } catch {
                debug("Failed to end workout: \(error))")
                return
            }
            
            workout = finishedWorkout
        #endif
    }
    
}

/* 
 Conforming WorkoutManager to be a confirmed delegator for HKLiveWorkoutBuilder, should it be run on watchOS.
 https://developer.apple.com/documentation/healthkit/hkliveworkoutbuilderdelegate
 */
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    /* Inherited from `HKLiveWorkoutBuilderDelegate.workoutBuilder`. Refrain from renaming or changing the signature of the following. */
    /** Tells the [WorkoutManager] that a new data has been created. */
    nonisolated func workoutBuilder ( _ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType> ) {
        
        /* 
         Because the watch is the one who's gathering all the data, make it to:
          1. classify the data it gathered, 
          2. update the statistics with accordance to the data gathered, and
          3. tell anyone who mirrored the session, about the data gathered.
         */
        Task { @MainActor in
            var allStatistics: [HKStatistics] = [ ]
            
            classifyCollectedDataAndUpdateTheStatistics ( workoutBuilder, collectedTypes, &allStatistics )
            await prepareDataForTransportAndSendIt(statistics: allStatistics)
        }
    }
    
    /** Tells the delegate that a new event has been added to the builder. */
    nonisolated func workoutBuilderDidCollectEvent ( _ workoutBuilder: HKLiveWorkoutBuilder ) {}
    
    fileprivate func classifyCollectedDataAndUpdateTheStatistics ( _ workoutBuilder: HKLiveWorkoutBuilder, _ collectedTypes: Set<HKSampleType>, _ allStatistics: inout [HKStatistics] ) {
        for type in collectedTypes {
            if let quantityType = type as? HKQuantityType, let statistics = workoutBuilder.statistics(for: quantityType) {
                updateForStatistics(statistics)
                
                allStatistics.append(statistics)
            }
        }
    }
    
    fileprivate func prepareDataForTransportAndSendIt ( statistics: [HKStatistics] ) async {
        let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: statistics, requiringSecureCoding: true)
        
        guard let archivedData = archivedData, !archivedData.isEmpty else {
            debug("Encoded cycling data is empty -- aborting the attempt to send data")
            
            return
        }
        
        await sendData(archivedData)
    }
    
}
