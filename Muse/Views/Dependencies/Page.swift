import SwiftUI

struct Page : Identifiable, Hashable {
    
    let   id = UUID()
    let name : String
    let icon : String
    let view : AnyView
    
    init ( name: String, icon: String, view: @escaping @autoclosure () -> any View ) {
        self.name = name
        self.icon = icon
        self.view = AnyView( view().named(name) )
    }
    
    /* Inherited from Hashable protocol. Refrain from modifying the following. */
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    /* Inherited from Hashable protocol. Refrain from modifying the following. */
    func hash ( into hasher: inout Hasher ) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
}
