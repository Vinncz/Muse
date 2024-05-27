import SwiftUI
import SwiftData

struct PreviouslyAttempted : View {
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutManager.self) var workoutManager: WorkoutManager
    @Query var queriedAttempts : [ Attempt ]
    
    var body: some View {
        VStack ( alignment: .leading, spacing: 0 ) {
            PreviousAttempts
            Spacer()
        }
    }
}

extension PreviouslyAttempted {
    var PreviousAttempts : some View {
        VStack ( alignment: .leading ) {
            Text( "Revisit the Moments" )
                .font(.title2)
                .bold()
                .padding(.horizontal, UIConfig.Paddings.huge - 4)
            
            ScrollView ( .horizontal, showsIndicators: false ) {
                HStack ( alignment: .top, spacing: UIConfig.Spacings.large ) {
                    ArrayOfImportedMusic
                    ImportMusic()
                }
                    .padding(.horizontal, UIConfig.Paddings.huge - 4)
            }
        }
        .padding( .top, UIConfig.Paddings.large )
    }
    
    var ArrayOfImportedMusic : some View {
        return ForEach ( queriedAttempts ) { attempt in
            NavigationLink {
                DetailedAttempt( attempt: attempt )
                    .transition(.move(edge: .bottom))
                
            } label: {
                MusicEntry (
                    artwork : AnyView( ArtworkSquare( Image(systemName: "music.note") ) ), 
                    title   : attempt.associatedMusic?.title ?? "Unknown music", 
                    desc    : attempt.associatedMusic?.artists ?? "Unknown artist"
                )
            }
            .buttonStyle(PlainButtonStyle()) 
        }
    }
}
