import SwiftUI

struct MediaPlayback: View {
    
    /* Environment variables needed by this page */
    @Environment(\.horizontalSizeClass) var screenSize
    @Environment(\.modelContext) private var modelContext
    
    /* Parameters which are expected by this page */
    let music : Music
    
    /* Mutating variables which are used by this page for various purposes */
    @State var measurementData : [MeasurementData] = [
        MeasurementData (
            amount: "89",
            unit  : "bpm",
            icon  : AnyView(Image(systemName: "heart.fill").foregroundStyle(.red)),
            label : "Heart rate"
        ),
        MeasurementData (
            amount: "129",
            unit  : "cals",
            icon  : AnyView(Image(systemName: "flame.fill").foregroundStyle(.red)),
            label : "Energy burned"
        )
    ]
    @Bindable var audioPlayer : AudioPlayer
    
    init ( _ _music: Music ) {
        self.music = _music
        self.audioPlayer = AudioPlayer(bookmark: music.bookmark)
    }
    
    var body: some View {
        HStack {
            PlaybackArea
            if ( screenSize == .regular ) {
                AttemptSidebar( data: measurementData)
            }
        }
            .onDisappear() {
                audioPlayer.stop()
            }
    }
    
}

struct MeasurementData : Identifiable {
    let id = UUID()
    
    var amount: String
    var unit  : String = ""
    var icon  : AnyView = AnyView(EmptyView())
    var label : String
}

extension MediaPlayback {
    
    /* The left-hand side of this page, where media playbacks occur and are controlled from */
    var PlaybackArea : some View {
        HStack {
            Spacer()
            if ( screenSize == .compact ){
                ScrollView ( .vertical ) {
                    PlaybackContent.padding()
                }
            } else {
                PlaybackContent.padding()
            }
            Spacer()
        }
    }
    
    var PlaybackContent : some View {
        VStack ( alignment: .center ) {
            MusicEntry (
                artwork : AnyView( 
                    ArtworkSquare( 
                        Image(systemName: "music.note")
                        ,size: UIConfig.SquareSizes.giant
                        ,font: .largeTitle
                    ) 
                ), 
                title              : music.title, 
                desc               : music.artists,
                width              : UIConfig.SquareSizes.giant + UIConfig.Spacings.huge * 2,
                alignment          : .center,
                multiLineAlignment : .center,
                titleFont          : .title,
                descFont           : .title3
            )
            PlaybackControlGroup
            if ( screenSize == .compact ) {
                AttemptCard( data: measurementData)
            }
        }
    }
    
    var PlaybackControlGroup : some View {
        VStack {
            PlaybackSeekbar
            HStack ( spacing: UIConfig.Spacings.huge * 2 ) {
                WatchConnectivityButton
                PlayPauseButton
                PlaybackSpeedDial
            }
            .padding()
        }
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
                ).font(.system(size: UIConfig.FontSizes.huge, weight: .ultraLight))
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
            VStack ( spacing: UIConfig.Spacings.mini) {
                Image( systemName: "dial" )
                    .font(.title)
                Text("\(audioPlayer.playbackSpeed, specifier: "%.1fx")")
                    .font(.headline)
                    .bold()
                    .opacity(0.75)
            }
        }
    }
    
    var WatchConnectivityButton : some View {
        Button {
            
        } label: {
            Image (
                systemName: "exclamationmark.applewatch"
            ).font(.system(size: UIConfig.FontSizes.mini - 4, weight: .regular))
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
        .frame( maxWidth: UIConfig.SquareSizes.giant * 2 )
    }
    
    /* The right-hand side of this page, where statistics are displayed */
    func AttemptSidebar ( data: [MeasurementData] ) -> some View {
        HStack {
            VStack ( alignment: .leading ) {
                VStack ( alignment: .leading ) {
                    Text("Current attempt")
                        .bold()
                        .opacity(0.4)
                    ForEach ( data ) { d in
                        CurrentAttemptMeasurementData ( data: d )
                            .background (
                                Color(.systemGray5).opacity(1), 
                                in: RoundedRectangle( cornerRadius: UIConfig.CornerRadiuses.mini )
                            )
                    }
                }
                
                Spacer()
            }
                .padding()
            Spacer()
        }
        .frame (
            maxWidth: UIConfig.SidebarSizes.huge
        )
        .background( Color(.systemGray6) )
    }
    
    func AttemptCard ( data: [MeasurementData] ) -> some View {
        return HStack ( alignment: .top ) {
            VStack ( alignment: .leading ) {
                Text("Current attempt")
                    .bold()
                    .opacity(0.4)
                HStack {
                    ForEach ( data ) { d in
                        CurrentAttemptMeasurementData( data: d )
                            .background (
                                Color(.systemGray4).opacity(0.5), 
                                in: RoundedRectangle( cornerRadius: UIConfig.CornerRadiuses.mini )
                            )
                    }
                }
            }
            Spacer()
        }
            .padding()
            .background (
                Color(.systemGray6)
            )
            .clipShape (
                RoundedRectangle(
                    cornerRadius: UIConfig.CornerRadiuses.large
                )
            )
    }
    
    func CurrentAttemptMeasurementData ( data: MeasurementData ) -> some View {        
        return VStack ( alignment: .leading ) {
            HStack ( alignment: .top, spacing: UIConfig.Spacings.mini ) {
                HStack ( alignment: .bottom, spacing: UIConfig.Spacings.mini ) {
                    Text(data.amount)
                        .font(.title)
                        .bold()
                    Text(data.unit)
                        .font(.footnote)
                        .bold()
                        .padding(.bottom, UIConfig.Paddings.micro)
                }
                Spacer()
                data.icon
            }
            Text(data.label)
                .font(.footnote)
        }
        .padding( .all, UIConfig.Paddings.large )
    }
    
    
}

#Preview {    
    MediaPlayback( 
        Music(
            _title: "September", 
            _artists: "Earth, Wind & Fire", 
            _attempts: [], 
            _url: URL(fileURLWithPath: ""), 
            _bookmark: try! URL(fileURLWithPath: "").bookmarkData()
        )
    )
}
