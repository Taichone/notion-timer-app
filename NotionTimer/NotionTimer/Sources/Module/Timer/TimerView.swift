//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct TimerView: View {
    // TODO: データ繋ぎこみ
//    @State private var isFocusMode = true
//    @State private var duration = 240.0
//    @State private var maxFocusTimeSec = 300.0
//    @State private var maxBreakTimeSec = 180.0
    
    @State private var viewModel: TimerViewModel
    
    init(timerSetting: TimerSetting, focusColor: Color, breakColor: Color) {
        let timerManager = TimerManager(timerSetting: timerSetting)
        self._viewModel = State(wrappedValue: TimerViewModel(timerManager: timerManager, focusColor: focusColor, breakColor: breakColor))
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
                Section {
                    Text("Mode: ") + Text(self.viewModel.timerMode == .focusMode ? "Focus" : "Break")
                    Text("Remaining Time: ") + Text(self.viewModel.displayTime)
                    Text("Total Focus Time: ") + Text(self.viewModel.displayTotalFocusTime)
                }
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

#Preview {
    NavigationStack {
        TimerView(
            timerSetting: .init(
                isBreakEndSoundEnabled: true,
                isManualBreakStartEnabled: true,
                focusTimeMin: 25,
                breakTimeMin: 5
            ),
            focusColor: .mint,
            breakColor: .pink
        )
    }
}
