//
//  TimerViewModel.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16.
//

import SwiftUI
import Combine

struct TimerSetting {
    var isBreakEndSoundEnabled: Bool
    var isManualBreakStartEnabled: Bool
    var focusTimeMin: Int
    var breakTimeMin: Int
}

@Observable
final class TimerViewModel {
    var displayTime: String = "00:00"
    var timerMode: TimerMode = .focusMode
    var isRunning: Bool = false
    
    private var timerManager: TimerManager
    private var cancellables = Set<AnyCancellable>()
    
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
        
        // `remainingTimeSec`が変化するたびに`displayTime`を更新
        timerManager.remainingTimeSec
            .map { remainingSec in
                String(format: "%02d:%02d", Int(remainingSec) / 60, Int(remainingSec) % 60)
            }
            .assign(to: $displayTime)
        
        // `timerMode`が変わるたびに表示を更新
        timerManager.$timerMode
            .assign(to: $timerMode)
        
        // `timerStatus`によって`isRunning`を更新
        timerManager.$timerStatus
            .map { $0 == .running }
            .assign(to: $isRunning)
    }
    
    func startTimer() {
        timerManager.start()
    }
    
    func pauseTimer() {
        timerManager.pause()
    }
    
    func terminateTimer() {
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
