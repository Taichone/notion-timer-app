//
//  TimerManager.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16.
//

import SwiftUI

enum TimerStatus {
    case running, pause
}

enum TimerMode {
    case focusMode, breakMode
}

@Observable
final class TimerManager {
    // Setting
    private let isManualBreakStartEnabled: Bool
    private let focusTimeSec: Double
    private let breakTimeSec: Double
    
    // Runtime
    var timerMode: TimerMode = .focusMode
    var remainingTimeSec: Double = 0
    var maxTimeSec: Double = 0
    var totalFocusTime = 0

    // Timer
    private var timer: Timer?
    private var timerStatus: TimerStatus?
    
    init(timerSetting: TimerSetting) {
        self.isManualBreakStartEnabled = timerSetting.isManualBreakStartEnabled
        self.focusTimeSec = Double(timerSetting.focusTimeMin) // ポモドーロ集中時間
        self.breakTimeSec = Double(timerSetting.breakTimeMin) // ポモドーロ休憩時間
    }
}

extension TimerManager {
    func start() {
        self.timerStatus = .running
        switch self.timerMode {
        case .focusMode:
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tickInFocusMode()
            }
        case . breakMode:
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tickInBreakMode()
            }
        }
    }
    
    func pause() {
        self.timerStatus = .pause
        self.stopTimer()
    }
    
    func terminate() {
        self.timerStatus = nil
        self.remainingTimeSec = 0
        self.stopTimer()
    }
    
    private func tickInFocusMode() {
        withAnimation {
            self.remainingTimeSec -= 1.0 // 残り時間
        }
        self.totalFocusTime += 1 // 合計集中時間
        
        if self.remainingTimeSec <= 0 {
            if self.isManualBreakStartEnabled {
                self.pause()
            }
            print("===集中終了") // TODO: 集中が終わった ことを示すイベントを発行して ViewModel へ
            self.changeToBreakMode()
        }
    }
    
    private func tickInBreakMode() {
        withAnimation {
            self.remainingTimeSec -= 1.0 // 残り時間
        }
        
        if self.remainingTimeSec <= 0 {
            print("===休憩終了") // TODO: 休憩が終わった ことを示すイベントを発行して ViewModel へ
            self.changeToFocusMode()
        }
    }
    
    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func changeToFocusMode() {
        self.timerMode = .focusMode
        self.maxTimeSec = self.focusTimeSec
        self.remainingTimeSec = Double(self.focusTimeSec)
    }
    
    private func changeToBreakMode() {
        self.timerMode = .breakMode
        self.maxTimeSec = self.breakTimeSec
        self.remainingTimeSec = Double(self.breakTimeSec)
    }
}
