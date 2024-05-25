import SwiftUI
import HealthKitUI

struct AuthorizeButton : View {
    @State var authenticated = false
    @State var sheetShown    = false
    
    let allTypes: Set = [
        HKQuantityType.workoutType(),
        HKQuantityType(.activeEnergyBurned),
        HKQuantityType(.heartRate)
    ]
    
    let healthStore = HKHealthStore()
    
    var body : some View {
        Button {
            sheetShown.toggle()
        } label: {
            Image(systemName: "checkmark.circle.badge.questionmark")
        }
        .healthDataAccessRequest(store: healthStore, shareTypes: allTypes, readTypes: allTypes, trigger: sheetShown) { result in
            LocalLogger.log(result)
            
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
