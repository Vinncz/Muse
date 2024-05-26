// Copyright © 2023 Apple Inc.

import HealthKit

extension HKWorkoutSessionState {
    var isActive : Bool {
        self != .notStarted && self != .ended
    }
}
