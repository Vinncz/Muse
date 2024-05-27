import Foundation
import SwiftData

@Model class Attempt {
    var associatedMusic: Music?
    var caloriesBurned : Double
    var playbackSpeed  : Double
    var createdAt      : Date
    
    init () {
        self.caloriesBurned  = 0
        self.playbackSpeed   = 1.0
        self.associatedMusic = nil
        self.createdAt       = .now
    }
    
    init (
        _associatedMusic: Music,
        _caloriesBurned : Double,
        _playbackSpeed  : Double
    ) {
        self.associatedMusic = _associatedMusic
        self.caloriesBurned  = _caloriesBurned
        self.playbackSpeed   = _playbackSpeed
        self.createdAt       = .now
    }
}
