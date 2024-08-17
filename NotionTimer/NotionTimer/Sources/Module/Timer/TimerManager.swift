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
    case focusMode, breakMode, extraFocusMode
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
    var totalFocusTimeSec = 0

    // Timer
    private var timer: Timer?
    var timerStatus: TimerStatus?
    
    init(timerSetting: TimerSetting) {
        self.isManualBreakStartEnabled = timerSetting.isManualBreakStartEnabled
        self.focusTimeSec = Double(timerSetting.focusTimeMin) * 60 // ポモドーロ集中時間
        self.breakTimeSec = Double(timerSetting.breakTimeMin) * 60 // ポモドーロ休憩時間
        self.changeToFocusMode()
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
            print("tickInFocusMode")
        case .breakMode:
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tickInBreakMode()
            }
            print("tickInBreakMode")
        case .extraFocusMode:
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.tickInExtraFocusMode()
            }
            print("tickInExtraFocusMode")
        }
    }
    
    func pause() {
        self.timerStatus = .pause
        self.stopTimer()
        print("pause")
    }
    
    func terminate() {
        self.timerStatus = nil
        self.remainingTimeSec = 0
        self.stopTimer()
        print("terminate")
    }
    
    func endExtraFocusAndStartBreak() {
        self.stopTimer()
        self.changeToBreakMode()
        self.start()
    }
    
    private func tickInFocusMode() {
        if self.remainingTimeSec > 0 {
            withAnimation { self.remainingTimeSec -= 1.0 }
            self.totalFocusTimeSec += 1 // 合計集中時間
        } else {
            // TODO: 集中が終わった ことを示すイベントを発行して ViewModel へ
            if self.isManualBreakStartEnabled {
                self.stopTimer()
                self.changeToExtraFocusMode()
                self.start()
            } else {
                self.stopTimer()
                self.changeToBreakMode()
                self.start()
            }
        }
    }
    
    private func tickInExtraFocusMode() {
        self.totalFocusTimeSec += 1 // 合計集中時間
    }
    
    private func tickInBreakMode() {
        if self.remainingTimeSec > 0 {
            withAnimation { self.remainingTimeSec -= 1.0 }
        } else {
            // TODO: 休憩が終わった ことを示すイベントを発行して ViewModel へ
            self.stopTimer()
            self.changeToFocusMode()
            self.start()
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
    
    private func changeToExtraFocusMode() {
        self.timerMode = .extraFocusMode
    }
    
    private func changeToBreakMode() {
        self.timerMode = .breakMode
        self.maxTimeSec = self.breakTimeSec
        self.remainingTimeSec = Double(self.breakTimeSec)
    }
}
