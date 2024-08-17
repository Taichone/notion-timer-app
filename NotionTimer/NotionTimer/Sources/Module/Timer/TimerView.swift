//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct TimerView: View {
    @State private var viewModel: TimerViewModel
    
    init(args: Self.Args) {
        let timerManager = TimerManager(args: .init(
            isManualBreakStartEnabled: args.isManualBreakStartEnabled,
            focusTimeMin: args.focusTimeMin,
            breakTimeMin: args.breakTimeMin
        ))
        self._viewModel = State(wrappedValue: TimerViewModel(
            timerManager: timerManager,
            focusColor: args.focusColor,
            breakColor: args.breakColor
        ))
    }
    
    var body: some View {
        VStack {
            ZStack {
                TimerCircle(color: Color(.gray).opacity(0.1))
                TimerCircle(
                    color: self.viewModel.timerCircleColor,
                    trimFrom: self.viewModel.trimFrom,
                    trimTo: self.viewModel.trimTo
                )
                .rotationEffect(Angle(degrees: -90))
                .shadow(radius: 10)
            }
            
            List {
                Text("Mode: ") + Text(self.viewModel.timerMode == .focusMode ? "Focus" : "Break")
                Text("Remaining Time: ") + Text(self.viewModel.displayTime)
                Text("Total Focus Time: ") + Text(self.viewModel.displayTotalFocusTime)
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.viewModel.tapPlayButton()
            } label: {
                Text(self.viewModel.isRunning ? "Pause" : "Resume").bold().padding()
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                self.viewModel.tapBreakStartButton()
            } label: {
                Text("Start Break").bold().padding()
            }.disabled(self.viewModel.timerMode != .extraFocusMode)
        }
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
    }
}

#Preview {
    NavigationStack {
        TimerView(args: .init(
            isBreakEndSoundEnabled: true,
            isManualBreakStartEnabled: true,
            focusTimeMin: 25,
            breakTimeMin: 5,
            focusColor: .mint,
            breakColor: .pink
        ))
    }
}
