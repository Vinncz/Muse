import SwiftUI

extension View {
    func named ( _ name : String ) -> some View { return self.navigationBarTitle(name) }
}

extension AnyView {
    func named ( _ name : String ) -> AnyView { return AnyView( self.navigationBarTitle(name) ) }
}
