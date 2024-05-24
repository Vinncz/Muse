import SwiftUI

struct MediaPlayback: View {
    
    /* Environment variables needed by this page */
    @Environment(\.horizontalSizeClass) var screenSize
    @Environment(\.modelContext) private var modelContext
    
    /* Parameters which are expected by this page */
    let music : Music
    
    /* Mutating variables that are used by this page for various purposes */
    @State var a = 0.0
    @Bindable var audioPlayer : AudioPlayer
    
    init ( _ _music: Music ) {
        self.music = _music
        self.audioPlayer = AudioPlayer(bookmark: music.bookmark)
    }
    
    var body: some View {
        HStack {
            PlaybackArea
            AttemptArea
        }
            .onDisappear() {
                audioPlayer.stop()
            }
    }
    
    /* The left-hand side of this page, where media playbacks occur and are controlled from */
    var PlaybackArea : some View {
        HStack {
            Spacer()
            VStack ( alignment: .center ) {
                Spacer()
                MusicEntry (
                    artwork : AnyView( 
                        ArtworkSquare( 
                            Image(systemName: "music.note")
                            ,size: UIConfigs.SquareSizes.giant
                            ,font: .largeTitle
                        ) 
                    ), 
                    title              : music.title, 
                    desc               : music.artists,
                    width              : UIConfigs.SquareSizes.giant + UIConfigs.Spacings.huge * 2,
                    alignment          : .center,
                    multiLineAlignment : .center,
                    titleFont          : .title,
                    descFont           : .title3
                )

                PlaybackControlGroup
                Spacer()
            }
                .padding()
            Spacer()
        }
    }
    
    /* The right-hand side of this page, where statistics are displayed */
    var AttemptArea : some View {
        HStack {
            VStack ( alignment: .leading ) {
                Text("Calories burned")
                Text("102kCal")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
            .padding()
            
            Spacer()
        }
        .frame (
            maxWidth: UIConfigs.SidebarSizes.huge
        )
        .background( Color(.systemGray5) )
    }
    
}

extension MediaPlayback {
    var PlaybackControlGroup : some View {
        VStack {
            PlaybackSeekbar
            HStack ( spacing: UIConfigs.Spacings.huge * 2 ) {
                WatchConnectivityButton
                PlayPauseButton
                PlaybackSpeedDial
            }
            .padding()
        }
        .padding()
    }
    
    var PlayPauseButton : some View {
        let systemIcon : String
        let audioPlayerIsPlaying = self.audioPlayer.isPlaying
        var closure    : () -> Void = {}
        
        if ( audioPlayerIsPlaying ) {
            systemIcon = "pause.circle.fill"
            closure    = {
                self.audioPlayer.pause()
            }
            
        } else {
            systemIcon = "play.circle.fill"
            closure    = {
                self.audioPlayer.play()
            }
        }
        
        return
            Button {
                closure()
            } label: {
                Image (
                    systemName:  systemIcon
                ).font(.system(size: UIConfigs.FontSizes.huge, weight: .ultraLight))
            }
    }
    
    var PlaybackSpeedDial : some View {
        Menu {
            Picker("Playback Speed", selection: $audioPlayer.playbackSpeed) {
                Text("0.8x").tag(Float(0.8))
                Text("1.0x").tag(Float(1.0))
                Text("1.15x").tag(Float(1.15))
                Text("1.25x").tag(Float(1.25))
                Text("1.5x").tag(Float(1.5))
                Text("1.8x").tag(Float(1.8))
                Text("2.0x").tag(Float(2.0))
            }
        } label: {
            VStack ( spacing: UIConfigs.Spacings.mini) {
                Image( systemName: "timer.circle" )
                    .font(.title)
                Text("\(audioPlayer.playbackSpeed, specifier: "%.1fx")")
                    .font(.headline)
                    .bold()
            }
        }
    }
    
    var WatchConnectivityButton : some View {
        Button {
            
        } label: {
            Image (
                systemName: "checkmark.applewatch"
            ).font(.system(size: UIConfigs.FontSizes.mini, weight: .regular))
        }
    }
    
    var PlaybackSeekbar : some View {
        Slider (
            value : $audioPlayer.seekTime,
            in    : 0...audioPlayer.duration,
            onEditingChanged: { s in
                audioPlayer.seek( to: audioPlayer.seekTime )
            }
        )
        .frame( maxWidth: UIConfigs.SquareSizes.giant * 2 )
    }
}

#Preview {    
    MediaPlayback( 
        Music(
            _title: "Hello, world", 
            _artists: "Kizuna Ai", 
            _attempts: [], 
            _url: URL(fileURLWithPath: ""), 
            _bookmark: try! URL(fileURLWithPath: "").bookmarkData()
        )
    )
}
