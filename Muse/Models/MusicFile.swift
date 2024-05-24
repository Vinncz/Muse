import Foundation

struct MusicFile : Identifiable, Hashable {
    let id       = UUID()
    
    let url      : URL
    let bookmark : Data
    let title    : String
    let artists  : String
    let type     : String
    let size     : Int
}
