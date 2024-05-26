import Foundation
import HealthKit

struct AppConfig {
    
    static let debug : Bool = true
    
    static let workoutLocation: HKWorkoutSessionLocationType = .indoor
    
    static let healthKitShareTypes : Set = [
        HKQuantityType.workoutType(),
        HKQuantityType(.activeEnergyBurned)
    ]
    static let healthKitReadTypes : Set = [
        HKQuantityType(.heartRate),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType.workoutType(),
        HKObjectType.activitySummaryType()
    ]
    
}
