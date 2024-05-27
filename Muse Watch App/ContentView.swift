import SwiftUI
import HealthKit
import os

struct ContentView: View {
    enum ScrollDirection {
        case up
        case down
    }
    
    @Environment(WorkoutManager.self) var workoutManager: WorkoutManager
    @State private var scrollDir : ScrollDirection = .down
    @State private var selection: Double = 0 {
        didSet {
            if ( selection > oldValue ) {
                scrollDir = .down
            } else if ( selection < oldValue ) {
                scrollDir = .up
            }
        }
    }

    var body: some View {
        HStack {
            VStack ( alignment: .leading ) {
                Text("Page \(Int(selection) + 1)")
                    .focusable(true)
                    .digitalCrownRotation($selection, from: 0, through: 2, by: 1, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)

                if Int(selection) == 0 {
                    HStack {
                        Text("Workout is present: \(workoutManager.workout != nil)")
                    }
                        .transition(.move(edge: self.scrollDir == .up ? .top : .bottom))
                    
                } else if Int(selection) == 1 {
                    PageView (
                        content: AnyView (
                            Button {
                                workoutManager.sessionState == .running ? workoutManager.session?.pause() : workoutManager.session?.resume()
                            } label: {
                                let title = workoutManager.sessionState == .running ? "Pause" : "Resume"
                                let systemImage = workoutManager.sessionState == .running ? "pause" : "play"
                                VStack {
                                    Image(systemName: systemImage)
                                    Text(title)
                                }
                            }
                                .disabled(!workoutManager.sessionState.isActive)
                                .tint(.blue)
                        )
                    )
                        .transition(.move(edge: self.scrollDir == .up ? .top : .bottom))
                    
                } else if Int(selection) == 2 {
                    PageView (
                        content: AnyView (
                            Button {
                                workoutManager.session?.stopActivity(with: .now)
                            } label: {
                                VStack {
                                    Image(systemName: "xmark")
                                    Text("End")
                                }
                            }
                                .tint(.red)
                                .disabled(!workoutManager.sessionState.isActive)
                        )
                    )
                        .transition(.move(edge: self.scrollDir == .up ? .top : .bottom))
                }
                
                Spacer()
            }
            
            Spacer()
        }
    }
    
    private func startWorkout() {
        Task {
            do {
                let configuration = HKWorkoutConfiguration()
                configuration.activityType = .cycling
                configuration.locationType = .outdoor
                try await workoutManager.startWorkout(workoutConfiguration: configuration)
                debug("tried to start the workout")
            } catch {
                debug("Failed to start workout \(error))")
            }
        }
    }
}

struct PageView: View {
    var content : AnyView

    var body: some View {
        content
            .background(.gray)
    }
}

#Preview {
    ContentView()
}
