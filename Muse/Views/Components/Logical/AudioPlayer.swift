import AVFoundation
import Foundation
import Observation

@Observable class AudioPlayer {
    
    /* Static */
    static var numberOfTimesCalled = 0
    
    /* Dependencies */
    private var audioPlayer    : AVAudioPlayer?
    private var playerDelegate : AudioPlayerDelegate = AudioPlayerDelegate()
    private var url            : URL?
    
    /* Mutating variables that are used by this component for various purposes */
    var seekTime         : TimeInterval = 0
    var duration         : TimeInterval = 0
    var playbackSpeed    : Float        = 1.0 {
        didSet {
            guard ( playbackSpeed >= 0.5 && playbackSpeed <= 2.0 ) else {
                playbackSpeed = oldValue
                return
            }
            
            self.audioPlayer?.rate = playbackSpeed
            let isInitiallyPlaying = self.audioPlayer?.isPlaying
            
            self.audioPlayer?.pause()
            if ( isInitiallyPlaying == true ) {
                self.audioPlayer?.play()
            }
        }
    }
    var isPlaying        : Bool         = false
    var audioPlayerCycle : Timer?
    
    /* Constants */
    let audioPlayerClockSpeed : TimeInterval = 0.1
    
    /* Helpers */
    let bookmark : Data
    
    init ( bookmark: Data ) {      
        AudioPlayer.numberOfTimesCalled += 1
        LocalLogger.log("AudioPlayer was called: \(AudioPlayer.numberOfTimesCalled)")
        
        self.bookmark = bookmark
        self.playerDelegate.didFinishPlaying = { [ weak self ] in
            self?.haltUpdatingSeekTime()
            self?.seekTime = 0
            
            self?.audioPlayer?.stop()
            self?.isPlaying = false
            
            self?.url?.stopAccessingSecurityScopedResource()
        }
        
        do {
            var isStale = false
            self.url = try URL (
                resolvingBookmarkData: bookmark, 
                bookmarkDataIsStale: &isStale
            )
            
            if let url = self.url {
                let access = url.startAccessingSecurityScopedResource()
                
                if ( access ) {
                    LocalLogger.log("Acess was granted")
                    self.audioPlayer = try AVAudioPlayer( contentsOf: url )
                    self.audioPlayer?.delegate = playerDelegate
                    
                } else {
                    LocalLogger.log("Acess was NOT granted")
                    
                }
                
            } else {
                LocalLogger.log("URL was empty")
                
            }
            
        } catch {
            LocalLogger.log("Failed to initialize AVAudioPlayer, due to \(error)")
            
        }
        
        duration = audioPlayer?.duration ?? 0        
    }
    
    func play () {
        audioPlayer?.enableRate = true
        audioPlayer?.rate       = playbackSpeed
        
        if ( audioPlayer?.prepareToPlay() == true ) {
            self.audioPlayer?.play()
        }
        self.isPlaying = audioPlayer?.isPlaying ?? false
        
        beginUpdatingSeekTime()
    }
    
    func pause () {
        self.audioPlayer?.pause()
        self.isPlaying = audioPlayer?.isPlaying ?? false
    }
    
    func stop () {
        self.audioPlayer?.stop()
        seekTime = 0
        self.isPlaying = audioPlayer?.isPlaying ?? false
    }
    
    func seek ( to time: TimeInterval ) {
        haltUpdatingSeekTime()
        
        self.audioPlayer?.currentTime = time
        self.seekTime = time
        
        if ( self.audioPlayer?.isPlaying == true ) {
            beginUpdatingSeekTime()
            self.isPlaying = self.audioPlayer!.isPlaying
        }
    }
    
    func playbackSpeed ( to speed: Float ) {
        self.playbackSpeed = speed
        
        if let player = self.audioPlayer, player.isPlaying {
            player.rate = speed
        }
    }
    
    private func beginUpdatingSeekTime () {
        /* invalidate any previous update cycle, if it hasn't already been invalidated */
        audioPlayerCycle?.invalidate()
        
        audioPlayerCycle = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.seekTime = self?.audioPlayer?.currentTime ?? 0
        }
    }
    
    private func haltUpdatingSeekTime () {
        audioPlayerCycle?.invalidate()
        audioPlayerCycle = nil
    }
}

@Observable class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var didFinishPlaying : ( () -> Void )?

    func audioPlayerDidFinishPlaying ( _ player: AVAudioPlayer, successfully flag: Bool ) {
        didFinishPlaying?()
    }
}
