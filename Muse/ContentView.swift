import SwiftUI

struct ContentView: View {
    
    init ( ) {
        activePage = presentablePages.first
    }
    
    var body : some View {
        NavigationSplitView {
            List ( presentablePages, selection: $activePage ) { page in
                NavigationLink ( value: page ) { 
                    Label( page.name, systemImage: page.icon )
                }
            }
                .navigationDestination( for: Page.self, destination: { page in
                    NavigationStack {
                        ScrollView ( .vertical ) {
                            page.view
                        }
                    }
                })
                .navigationTitle(Bundle.main.appName! as String)
            
        } detail: {
            NavigationStack {
                ScrollView ( .vertical ) {
                    activePage?.view
                }
            }  
            
        }
            .onAppear {
                    activePage = presentablePages.first
                }
    }

    @Environment(WorkoutManager.self) var workoutManager: WorkoutManager
    
    /* Mutating variables which are used by this page for various purposes */
    @State private var activePage: Page? = nil
    
    /* Constants that are used by this page for various purposes */
    let presentablePages : [ Page ] = [
        Page (
            name: "Library", 
            icon: "books.vertical", 
            view: Library() 
        ),
        Page ( 
            name: "InitView", 
            icon: "number", 
            view: initView() 
        )
    ]
    
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
