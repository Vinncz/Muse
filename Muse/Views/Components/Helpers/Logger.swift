import Foundation

class Logger {
    
    static func log ( _ arg : Any ) {
        guard ( Configs.debug == true ) else { return }
        
        print(arg)
    } 
    
}
