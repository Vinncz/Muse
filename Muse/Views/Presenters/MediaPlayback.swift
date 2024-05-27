import HealthKit
import SwiftUI
import os

/** A presentable page. It shows and controls the playback of a media. Usually, you'll navigate here through Library page. */
struct MediaPlayback: View {
    
    init ( _ _music: Music ) {
        self.music = _music
        self.audioPlayer = AudioPlayer(bookmark: music.bookmark)
    }
    
    var body: some View {
        HStack {
            PlaybackArea
            if ( screenSize == .regular ) {
                AttemptSidebar()
            }
        }
            .onDisappear() {
                audioPlayer.stop()
            }
    }
    
    /* Environment variables needed by this page */
    @Environment(\.horizontalSizeClass) var screenSize
    @Environment(\.modelContext) private var modelContext
    @Environment(WorkoutManager.self) var workoutManager: WorkoutManager
    
    /* Parameters which are expected by this page */
    let music : Music
    
    /* Mutating variables which are used by this page for various purposes */
    @Bindable var audioPlayer  : AudioPlayer
    @State var measurementData : [MeasurementData] = [
        MeasurementData (
            amount: "89",
            unit  : "bpm",
            icon  : AnyView(Image(systemName: "heart.fill").foregroundStyle(.red)),
            label : "Heart rate"
        ),
        MeasurementData (
            amount: "124",
            unit  : "cals",
            icon  : AnyView(Image(systemName: "flame.fill").foregroundStyle(.red)),
            label : "Energy burned"
        )
    ]
    @State var warningSheetShown : Bool = false
    @State var warningSheetAlreadyShown : Bool = false
    @State var permissionSheetShown : Bool = false
    @State var permissionSheetAlreadyShown : Bool = false
    @State var rememberSheetShown : Bool = false
    @State var rememberSheetAlreadyShown : Bool = false
    
}

struct MeasurementData : Identifiable {
    let id = UUID()
    
    var amount: String
    var unit  : String = ""
    var icon  : AnyView = AnyView(EmptyView())
    var label : String
}

extension MediaPlayback {
    
    /* The left-hand side of this page, where media playbacks occur, and are controlled from */
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
                AttemptCard()
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
                let hasRequestedPermission = UserDefaults.standard.bool(forKey: "has-requested-permission")
                debug("has requested permission: \(hasRequestedPermission)")
                guard ( hasRequestedPermission ) else {
                    warningSheetShown = true
                    return
                } 
                closure()
            } label: {
                Image (
                    systemName:  systemIcon
                )
                    .font (
                        .system (
                            size: UIConfig.FontSizes.huge, 
                            weight: .ultraLight
                        )
                    )
            }
        
            .sheet ( isPresented: $warningSheetShown ) {
                    WarningSheet
                }
        
            .healthDataAccessRequest ( store: AppValueProvider.healthStore, shareTypes: AppConfig.healthKitShareTypes, readTypes: AppConfig.healthKitReadTypes, trigger: permissionSheetShown ) { result in
                    switch ( result ) {
                        case .success(_):
                            permissionSheetShown = false
                            permissionSheetAlreadyShown = true
                            rememberSheetShown = true
                            debug("Successfully requested permission")
                        case .failure(let error):
                            debug("Failed to request permission: \(error)")
                    }
                }
        
            .sheet ( isPresented: $rememberSheetShown ) {
                    rememberSheetAlreadyShown = true
                    UserDefaults.standard.set(true, forKey: "has-requested-permission")
                } content: {
                    RememberSheet
                }
    }
    
    var PlaybackSpeedDial : some View {
        Menu {
            Picker( "Playback Speed", selection: $audioPlayer.playbackSpeed ) {
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
    
    private func wakeWatchIfHadNotAlreadyAndBeginWorkout ( ) {
        Task {
            do {
                try await workoutManager.startWatchWorkout()
                debug("tried to start cycling on watch")
            } catch {
                debug("Failed to start cycling on the paired watch.")
            }
        }
    }
    
    var WatchConnectivityButton : some View {
        Button {
            wakeWatchIfHadNotAlreadyAndBeginWorkout()
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
//    func AttemptSidebar ( data: [MeasurementData] ) -> some View {        
//        return HStack {
//            VStack ( alignment: .leading, spacing: UIConfig.Spacings.huge ) {
//                VStack ( alignment: .leading ) {
//                    Text("Current attempt")
//                        .bold()
//                        .opacity(0.4)
//                    ForEach ( data ) { d in
//                        CurrentAttemptMeasurementData ( data: d )
//                            .background (
//                                Color(.systemGray5).opacity(1), 
//                                in: RoundedRectangle( cornerRadius: UIConfig.CornerRadiuses.mini )
//                            )
//                    }
//                }
//                
//                if ( AppConfig.debug ) {
//                    Button ( role: .destructive ) {
//                        UserDefaults.standard.set(false, forKey: "has-requested-permission")
//                    } label: {
//                        Spacer()
//                        Text("Reset permission sheet")
//                            .padding( UIConfig.Paddings.normal )
//                        Spacer()
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//                
//                Spacer()
//            }
//                .padding()
//            Spacer()
//        }
//            .frame (
//                maxWidth: UIConfig.SidebarSizes.huge
//            )
//            .background( Color(.systemGray6) )
//    }
    
//    func AttemptCard ( data: [MeasurementData] ) -> some View {
//        return HStack ( alignment: .top ) {
//            VStack ( alignment: .leading ) {
//                Text("Current attempt")
//                    .bold()
//                    .opacity(0.4)
//                HStack {
//                    ForEach ( data ) { d in
//                        CurrentAttemptMeasurementData( data: d )
//                            .background (
//                                Color(.systemGray4).opacity(0.5), 
//                                in: RoundedRectangle( cornerRadius: UIConfig.CornerRadiuses.mini )
//                            )
//                    }
//                }
//            }
//            Spacer()
//        }
//            .padding()
//            .background (
//                Color(.systemGray6)
//            )
//            .clipShape (
//                RoundedRectangle(
//                    cornerRadius: UIConfig.CornerRadiuses.large
//                )
//            )
//    }
    
    var WarningSheet : some View {
        VStack ( alignment: .leading, spacing: UIConfig.Spacings.large ) {
            Text("Hold up!")
                .font(.largeTitle)
                .bold()
                .padding( .top, UIConfig.Paddings.huge )
            
            ScrollView {
                Text(
                    """
                    In the next screen, you'll be prompted with Health access confirmation.
                    
                    This happens because Muse gonna need to access your health data: to visualize how your workout is currently progressing. 

                    These visualization includes displaying how quick your heart rate is, how many calories have you burned during a music’s playback, and what is your best score to a particular song is.

                    Don’t worry, your data will always stay with your Apple account.
                    """
                )
                .padding( .all, UIConfig.Paddings.normal )
            }
            
            Spacer()
            
            Button {
                warningSheetShown = false
                warningSheetAlreadyShown = true
                permissionSheetShown = true
            } label: {
                Spacer()
                Text("Okay, I understand")
                    .padding( .all, UIConfig.Paddings.normal )
                Spacer()
            }
                .buttonStyle(.borderedProminent)
        }
            .padding( .all, UIConfig.Paddings.huge )
    }
    
    var RememberSheet : some View {
        VStack ( alignment: .leading, spacing: UIConfig.Spacings.large ) {
            Text("Do remember!")
                .font(.largeTitle)
                .bold()
                .padding( .top, UIConfig.Paddings.huge )
            
            ScrollView {
                Text(
                    """
                    If the data displayed on the right doesn’t budge, it might be either because your watch takes time to sync all that data, or you might accidentally didn’t give Muse the required permission to read your health data.

                    No worries though, you can always head over to Settings > Privacy & Security > Health and give Muse the permission it requires.  After the watch has successfully synced all that, you’ll be able to see your data in graph on the “attempt” screen. Head there by using the sidebar on the left.
                    """
                )
                    .padding( .all, UIConfig.Paddings.normal )
            }
            
            Spacer()
            
            Button {
                rememberSheetAlreadyShown = true
                UserDefaults.standard.set(true, forKey: "has-requested-permission")
                rememberSheetShown = false
            } label: {
                Spacer()
                Text("Sweet")
                    .padding( .all, UIConfig.Paddings.normal )
                Spacer()
            }
                .buttonStyle(.borderedProminent)
        }
            .padding( .all, UIConfig.Paddings.huge )
    }
}

struct CurrentAttemptMeasurementData : View {   
    let data: MeasurementData
    
    var body : some View {
        VStack ( alignment: .leading ) {
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

struct AttemptCard : View {
    @Environment(WorkoutManager.self) var workoutManager : WorkoutManager
    
    var body : some View {
        let fromDate = workoutManager.session?.startDate ?? Date()
        let schedule = MetricsTimelineSchedule( from: fromDate, isPaused: workoutManager.sessionState == .paused )
        return 
            HStack ( alignment: .top ) {
                VStack ( alignment: .leading ) {
                    Text("Current attempt")
                        .bold()
                        .opacity(0.4)
                    TimelineView( schedule ) { context in 
                        List {
                            Section {
                                Group {
                                    LabeledContent("Heart rate", value: workoutManager.workoutValues.heartRate, format: .number.precision(.fractionLength(0)))
                                    LabeledContent("Calories burned", value: workoutManager.workoutValues.activeEnergyBurned, format: .number.precision(.fractionLength(0)))
                                }
                            } header: {
                                ElapsedTimeView(elapsedTime: workoutTimeInterval(context.date), showSubseconds: context.cadence == .live)
                            } footer: {
                                VStack {
                                    Spacer(minLength: 40)
                                    HStack {
                                        Button {
                                            if let session = workoutManager.session {
                                                workoutManager.sessionState == .running ? session.pause() : session.resume()
                                            }
                                        } label: {
                                            let title = workoutManager.sessionState == .running ? "Pause" : "Resume"
                                            let systemImage = workoutManager.sessionState == .running ? "pause" : "play"
                                            Image(systemName: systemImage)
                                            Text(title)
                                        }
                                        .disabled(!workoutManager.sessionState.isActive)
                                        
                                        Button {
                                            workoutManager.session?.stopActivity(with: .now )
                                        } label: {
                                            Image(systemName: "xmark")
                                            Text("End")
                                        }
                                        .tint(.green)
                                        .disabled(!workoutManager.sessionState.isActive)
                                        
                                        Spacer()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .background (
                    Color(.systemGray6)
                )
//                .clipShape (
//                    RoundedRectangle(
//                        cornerRadius: UIConfig.CornerRadiuses.large
//                    )
//                )
        }
    }
}

struct AttemptSidebar : View {
    @Environment(WorkoutManager.self) var workoutManager : WorkoutManager
    
    var body : some View {
        let fromDate = workoutManager.session?.startDate ?? Date()
        let schedule = MetricsTimelineSchedule( from: fromDate, isPaused: workoutManager.sessionState == .paused )
        HStack {
            VStack ( alignment: .leading, spacing: UIConfig.Spacings.huge ) {
                VStack ( alignment: .leading ) {
                    Text("Current attempt")
                        .bold()
                        .opacity(0.4)
                    TimelineView( schedule ) { context in 
                        List {
                            Section {
                                Group {
                                    LabeledContent("Heart rate", value: workoutManager.workoutValues.heartRate, format: .number.precision(.fractionLength(0)))
                                    LabeledContent("Calories burned", value: workoutManager.workoutValues.activeEnergyBurned, format: .number.precision(.fractionLength(0)))
                                }
                            } header: {
                                ElapsedTimeView(elapsedTime: workoutTimeInterval(context.date), showSubseconds: context.cadence == .live)
                            } footer: {
                                VStack {
                                    Spacer(minLength: 40)
                                    HStack {
                                        Button {
                                            if let session = workoutManager.session {
                                                workoutManager.sessionState == .running ? session.pause() : session.resume()
                                            }
                                        } label: {
                                            let title = workoutManager.sessionState == .running ? "Pause" : "Resume"
                                            let systemImage = workoutManager.sessionState == .running ? "pause" : "play"
                                            Image(systemName: systemImage)
                                            Text(title)
                                        }
                                        .disabled(!workoutManager.sessionState.isActive)

                                        Button {
                                            workoutManager.session?.stopActivity(with: .now )
                                        } label: {
                                            Image(systemName: "xmark")
                                            Text("End")
                                        }
                                        .tint(.green)
                                        .disabled(!workoutManager.sessionState.isActive)

                                        Spacer()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                }
                
                if ( AppConfig.debug ) {
                    Button ( role: .destructive ) {
                        UserDefaults.standard.set(false, forKey: "has-requested-permission")
                    } label: {
                        Spacer()
                        Text("Reset permission sheet")
                            .padding( UIConfig.Paddings.normal )
                        Spacer()
                    }
                    .buttonStyle(.borderedProminent)
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
}

extension AttemptSidebar {
    @MainActor private func workoutTimeInterval(_ contextDate: Date) -> TimeInterval {
        var timeInterval = workoutManager.elapsedTimeInterval
        if workoutManager.sessionState == .running {
            if let referenceContextDate = workoutManager.contextDate {
                timeInterval += (contextDate.timeIntervalSinceReferenceDate - referenceContextDate.timeIntervalSinceReferenceDate)
            } else {
                workoutManager.contextDate = contextDate
            }
        } else {
            var date = contextDate
            date.addTimeInterval(workoutManager.elapsedTimeInterval)
            timeInterval = date.timeIntervalSinceReferenceDate - contextDate.timeIntervalSinceReferenceDate
            workoutManager.contextDate = nil
        }
        return timeInterval
    }
}
    
extension AttemptCard {
    @MainActor private func workoutTimeInterval(_ contextDate: Date) -> TimeInterval {
        var timeInterval = workoutManager.elapsedTimeInterval
        if workoutManager.sessionState == .running {
            if let referenceContextDate = workoutManager.contextDate {
                timeInterval += (contextDate.timeIntervalSinceReferenceDate - referenceContextDate.timeIntervalSinceReferenceDate)
            } else {
                workoutManager.contextDate = contextDate
            }
        } else {
            var date = contextDate
            date.addTimeInterval(workoutManager.elapsedTimeInterval)
            timeInterval = date.timeIntervalSinceReferenceDate - contextDate.timeIntervalSinceReferenceDate
            workoutManager.contextDate = nil
        }
        return timeInterval
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
