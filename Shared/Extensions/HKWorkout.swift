// Copyright © 2023 Apple Inc.
// This file partly contains copyrighted (MIT Licensed) works of Apple Inc.

import Foundation
import HealthKit

extension HKWorkout {
    var totalTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? ""
    }
    
    var totalEnergy: String {
        var value: Double = 0
        if let statistics = statistics(for: HKQuantityType(.activeEnergyBurned)),
           let sum = statistics.sumQuantity() {
            value = sum.doubleValue(for: .smallCalorie())
        }
        let measurement = Measurement(value: value, unit: UnitEnergy.kilocalories)
        let numberStyle = FloatingPointFormatStyle<Double>.number.precision(.fractionLength(0))
        return measurement.formatted(.measurement(width: .abbreviated, usage: .workout, numberFormatStyle: numberStyle))
    }
    
    var averageHeartRate: String {
        var value: Double = 0
        if let statistics = statistics(for: HKQuantityType(.heartRate)),
           let average = statistics.averageQuantity() {
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            value = average.doubleValue(for: heartRateUnit)
        }
        return value.formatted(.number.precision(.fractionLength(0))) + " bpm"
    }
}
