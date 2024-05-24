import SwiftUI
import SwiftData

struct Library: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query var musics : [ Music ]
    
    var body: some View {
        VStack ( alignment: .leading, spacing: 0 ) {
            MyMusics
            PreviouslyPlayed
            Spacer()
        }
            .padding(.horizontal, UIConfigs.Paddings.mini)
    }
    
    
    
    /* Start of File-specific Components area */
        var MyMusics : some View {
            VStack ( alignment: .leading ) {
                Text( SectionHeader.myMusics )
                    .font(.title2)
                    .bold()
                
                ScrollView ( .horizontal, showsIndicators: false ) {
                    HStack ( alignment: .top ) {
                        ArrayOfImportedMusic
                        
                        ImportMusic()
                    }
                }
            }
                .padding()
        }
        
        var PreviouslyPlayed : some View {
            VStack ( alignment: .leading ) {
                Text( SectionHeader.previouslyPlayed )
                    .font(.title2)
                    .bold()
                
                ScrollView ( .horizontal, showsIndicators: false ) {
                    HStack ( alignment: .top ) {
                        ArrayOfPreviouslyPlayedMusic.view
                        
                        if ( ArrayOfPreviouslyPlayedMusic.absent ) {
                            MusicEntry (
                                artwork : AnyView(
                                    ArtworkSquare( 
                                        Image(systemName: "flame"),
                                        backgroundColor: .orange.opacity(0.75)
                                    )
                                ), 
                                title   : "Let's play some music!", 
                                desc    : "You haven't played any, yet."
                            )
                        }
                    }
                }
            }.padding()
        }
    
        var ArrayOfImportedMusic : some View {
            return ForEach ( musics ) { music in
                NavigationLink {
                    MediaPlayback( music )
                        .transition(.move(edge: .bottom))
                    
                } label: {
                    MusicEntry (
                        artwork : AnyView(
                            ArtworkSquare( Image(systemName: "music.note") )
                        ), 
                        title   : music.title, 
                        desc    : music.artists
                    )
                }
                    .buttonStyle(PlainButtonStyle()) 
            }
        }
        
        var ArrayOfPreviouslyPlayedMusic : ( 
            view    : ForEach<[Music], PersistentIdentifier, some View>, 
            absent : Bool
        ) {
            let previouslyPlayedMusics = musics.filter({ m in
                m.attempts.count > 0
            })
            let noMusicHasBeenPlayed : Bool = previouslyPlayedMusics.isEmpty
            
            return (
                ForEach ( previouslyPlayedMusics ) { music in
                    NavigationLink {
                        MediaPlayback( music )
                            .transition(.move(edge: .bottom))
                        
                    } label: {
                        MusicEntry (
                            artwork : AnyView(
                                ArtworkSquare( Image(systemName: "flame") )
                            ), 
                            title   : music.title, 
                            desc    : music.artists
                        )
                    }
                }, 
                
                noMusicHasBeenPlayed
            )
        }
    /* End of File-specific Components area */
    
}

#Preview {
    Library()
}

struct initView : View {
    @Query private var items: [Item]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
