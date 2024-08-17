//
//  TimerViewModel.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16. //
import SwiftUI
import Combine

struct TimerSetting {
    var isBreakEndSoundEnabled: Bool
    var isManualBreakStartEnabled: Bool
    var focusTimeMin: Int
    var breakTimeMin: Int
}

@Observable
class TimerViewModel {
    private var timerManager: TimerManager
    
    private let focusColor: Color
    private let breakColor: Color
    
    // TODO: コンピューテッドではなく timerManager からのイベントで更新する
    var timerCircleColor: Color {
        if timerMode == .focusMode {
            return self.focusColor
        } else {
            return self.breakColor
        }
    }
    
    var trimFrom: CGFloat {
        if timerMode == .focusMode {
            return CGFloat(1 - (remainingTimeSec / timerManager.maxTimeSec))
        } else {
            return 0
        }
    } // CGFloat((self.viewModel.timerMode == .focusMode) ? (1 - (self.duration / Double(self.viewModel.maxTimeSec))) : 0),
    
    var trimTo: CGFloat {
        if timerMode == .focusMode {
            return 1
        } else {
            return CGFloat(1 - (remainingTimeSec / timerManager.maxTimeSec))
        }
    } // CGFloat((self.viewModel.timerMode == .focusMode) ? 1 : (1 - (self.duration / Double(self.viewModel.maxTimeSec))))
    
    var displayTime: String {
        String(format: "%02d:%02d", Int(timerManager.remainingTimeSec) / 60, Int(timerManager.remainingTimeSec) % 60)
    }
    
    var displayTotalFocusTime: String {
        String(format: "%02d:%02d", Int(timerManager.totalFocusTimeSec) / 60, Int(timerManager.totalFocusTimeSec) % 60) }
    
    var timerMode: TimerManager.Mode {
        timerManager.timerMode
    }
    
    var isRunning: Bool {
        timerManager.timerStatus == .running
    }
    
    var remainingTimeSec: Double {
        timerManager.remainingTimeSec
    }
    
    // TODO: viewModel, timerManager 値の渡し方を綺麗にしたい
    init(timerManager: TimerManager, focusColor: Color, breakColor: Color) {
        self.timerManager = timerManager
        self.focusColor = focusColor
        self.breakColor = breakColor
    }
    
    // MARK: User Action
    func tapPlayButton() {
        self.timerManager.timerStatus == .running ? pauseTimer() : startTimer()
    }
    
    func tapBreakStartButton() {
        self.timerManager.endExtraFocusAndStartBreak()
    }
    
    // MARK: Control Timer
    private func startTimer() {
        timerManager.start()
    }
    
    private func pauseTimer() {
        timerManager.pause()
    }
    
    private func terminateTimer() {
        timerManager.terminate()
    }
}

/*
 var focusColor: Color = .init(red: 0, green: 1, blue: 0.8)
 var breakColor: Color = .init(red: 1, green: 0, blue: 0.5)
 
 private func formatRemainingTime(sec: Double) -> String {
     // 残り時間 (ceil(Double) で切り上げの値を表示)
     let min = Int(ceil(sec)) % 3600 / 60
     let sec = Int(ceil(sec)) % 3600 % 60
     return String(format: min >= 10 ? "%02d:%02d" : "%01d:%02d", min, sec)
 }
 */
