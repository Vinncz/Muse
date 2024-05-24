import Foundation
import SwiftData

@Model class Music {
    var title    : String
    var artists  : String
    var attempts : [Attempt]
    @Attribute(.unique) var url      : URL
    @Attribute(.unique) var bookmark : Data
    
    init (
        _title : String,
        _artists : String,
        _attempts : [Attempt],
        _url : URL,
        _bookmark : Data
    ) {
        self.title = _title
        self.artists = _artists
        self.attempts = _attempts
        self.url = _url
        self.bookmark = _bookmark
    }
}
