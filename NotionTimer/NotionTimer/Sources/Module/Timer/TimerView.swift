//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import ManagedSettings

struct TimerView: View {
    @StateObject private var viewModel: TimerViewModel
    
    init(args: Args) {
        let timerManager = TimerManager(args: .init(
            isManualBreakStartEnabled: args.isManualBreakStartEnabled,
            focusTimeMin: args.focusTimeMin,
            breakTimeMin: args.breakTimeMin
        ))
        self._viewModel = StateObject(wrappedValue: TimerViewModel(
            timerManager: timerManager,
            focusColor: args.focusColor,
            breakColor: args.breakColor,
            screenTimeAPI: ScreenTimeAPI.shared,
            restrictedApps: args.restrictedApps
        ))
    }
    
    var body: some View {
        VStack {
            ZStack {
                TimerCircle(color: Color(.gray).opacity(0.1))
                TimerCircle(
                    color: self.viewModel.modeColor,
                    trimFrom: self.viewModel.trimFrom,
                    trimTo: self.viewModel.trimTo
                )
                .animation(.smooth, value: self.viewModel.trimFrom)
                .animation(.smooth, value: self.viewModel.trimTo)
                .rotationEffect(Angle(degrees: -90))
                .shadow(radius: 10)
            }
            
            List {
                HStack {
                    Text({switch self.viewModel.timerMode {
                        case .focusMode: "Focus Mode"
                        case .breakMode: "Break Mode"
                        case .additionalFocusMode: "Additional Focus Mode"
                    }}())
                }
                
                HStack {
                    Text("Remaining Time")
                    Spacer()
                    Text(self.viewModel.remainingTimeString)
                }
                
                HStack {
                    Text("Total Focus Time")
                    Spacer()
                    Text(self.viewModel.totalFocusTimeString)
                }
            }
            
            Button {
                Self.hapticFeedback.impactOccurred()
                self.viewModel.tapBreakStartButton()
            } label: {
                Text("Start Break").bold()
            }
            .hidden(self.viewModel.timerMode != .additionalFocusMode)
            
            Button {
                Self.hapticFeedback.impactOccurred()
                self.viewModel.tapPlayButton()
            } label: {
                Image(systemName: self.viewModel.timerButtonSystemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground)) // List 背景色に合わせる
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AfterTimerView()) {
                    Text("Done")
                }
            }
        }
    }
}

extension TimerView {
    struct Args {
        let isBreakEndSoundEnabled: Bool
        let isManualBreakStartEnabled: Bool
        let focusTimeMin: Int
        let breakTimeMin: Int
        let focusColor: Color
        let breakColor: Color
        let restrictedApps: Set<ApplicationToken>?
    }
}

extension TimerView {
    static let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
}

#Preview {
    NavigationStack {
        TimerView(args: .init(
            isBreakEndSoundEnabled: true,
            isManualBreakStartEnabled: true,
            focusTimeMin: 25,
            breakTimeMin: 5,
            focusColor: .mint,
            breakColor: .pink,
            restrictedApps: nil
        ))
    }
}
