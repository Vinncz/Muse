import Foundation

class LocalLogger {
    
    static func log ( _ arg : Any ) {
        guard ( AppConfig.debug == true ) else { return }
        
        print(arg)
    } 
    
}
