import SwiftUI
import HealthKitUI

struct AuthorizeButton : View {
    @State var authenticated = false
    @State var sheetShown    = false
    
    var body : some View {
        Button {
            sheetShown.toggle()
        } label: {
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
        .healthDataAccessRequest ( 
            store      : AppValueProvider.healthStore, 
            shareTypes : AppConfig.healthKitShareTypes, 
            readTypes  : AppConfig.healthKitReadTypes, 
            trigger    : sheetShown 
        ) { result in
            debug("\(result)")
            
            switch result {
                case .success(let a):
                    authenticated = a
                    break
                    
                case .failure(let error):
                    fatalError("*** An error occurred while requesting authentication: \(error) ***")
                    break
            }
        }
    }
}
