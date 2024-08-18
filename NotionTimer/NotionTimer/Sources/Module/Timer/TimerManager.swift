//
//  TimerManager.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16.
//

import Foundation
import Combine

final class TimerManager {
    // Args
    private let isManualBreakStartEnabled: Bool
    private let focusTimeSec: Int
    private let breakTimeSec: Int
    
    // Runtime
    @Published var timerMode: Mode = .focusMode
    @Published var remainingTimeSec: Int = 0
    @Published var maxTimeSec: Int = 0
    @Published var totalFocusTimeSec: Int = 0
    @Published var isRunning = false

    // Timer
    private var timer: Timer?

    init(args: Args) {
        self.isManualBreakStartEnabled = args.isManualBreakStartEnabled
        self.focusTimeSec = args.focusTimeMin * 60
        self.breakTimeSec = args.breakTimeMin * 60
        self.changeToFocusMode()
    }
}

extension TimerManager {
    func start() {
        self.isRunning = true
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
        self.isRunning = false
        self.stopTimer()
        print("pause")
    }
    
    func endExtraFocusAndStartBreak() {
        self.stopTimer()
        self.changeToBreakMode()
        self.start()
    }
    
    private func tickInFocusMode() {
        if self.remainingTimeSec > 0 {
            self.remainingTimeSec -= 1
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
            self.remainingTimeSec -= 1
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
        self.remainingTimeSec = self.focusTimeSec
    }
    
    private func changeToExtraFocusMode() {
        self.timerMode = .extraFocusMode
    }
    
    private func changeToBreakMode() {
        self.timerMode = .breakMode
        self.maxTimeSec = self.breakTimeSec
        self.remainingTimeSec = self.breakTimeSec
    }
}

extension TimerManager {
    enum Mode: String {
        case focusMode = "Focus"
        case breakMode = "Break"
        case extraFocusMode = "Extra Focus"
    }
}

extension TimerManager {
    struct Args {
        let isManualBreakStartEnabled: Bool
        let focusTimeMin: Int
        let breakTimeMin: Int
    }
}
