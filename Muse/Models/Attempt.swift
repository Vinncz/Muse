import Foundation
import SwiftData

@Model class Attempt {
    var caloriesBurned : Double
    var playbackSpeed  : Double
    
    init () {
        self.caloriesBurned = 0
        self.playbackSpeed  = 1.0
    }
    
    init (
        _caloriesBurned : Double,
        _playbackSpeed  : Double
    ) {
        self.caloriesBurned = _caloriesBurned
        self.playbackSpeed  = _playbackSpeed
    }
}
