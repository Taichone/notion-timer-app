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
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tickInFocusMode()
            }
        case .breakMode:
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tickInBreakMode()
            }
        case .additionalFocusMode:
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tickInAdditionalFocusMode()
            }
        }
    }
    
    func pause() {
        self.stopTimer()
    }
    
    func endAdditionalFocusAndStartBreak() {
        self.stopTimer()
        self.changeToBreakMode()
        self.start()
    }
    
    func terminate() {
        self.totalFocusTimeSec = 0
        self.stopTimer()
        self.changeToFocusMode()
    }
    
    private func tickInFocusMode() {
        if self.remainingTimeSec > 0 {
            self.remainingTimeSec -= 1
            self.totalFocusTimeSec += 1
        } else {
            if self.isManualBreakStartEnabled {
                self.stopTimer()
                self.changeToAdditionalFocusMode()
                self.start()
            } else {
                self.stopTimer()
                self.changeToBreakMode()
                self.start()
            }
        }
    }
    
    private func tickInAdditionalFocusMode() {
        self.totalFocusTimeSec += 1
    }
    
    private func tickInBreakMode() {
        if self.remainingTimeSec > 0 {
            self.remainingTimeSec -= 1
        } else {
            self.stopTimer()
            self.changeToFocusMode()
            self.start()
        }
    }
    
    private func stopTimer() {
        self.isRunning = false
        self.timer?.invalidate()
        self.timer = nil
    }
    
    private func changeToFocusMode() {
        self.timerMode = .focusMode
        self.maxTimeSec = self.focusTimeSec
        self.remainingTimeSec = self.focusTimeSec
    }
    
    private func changeToAdditionalFocusMode() {
        self.timerMode = .additionalFocusMode
    }
    
    private func changeToBreakMode() {
        self.timerMode = .breakMode
        self.maxTimeSec = self.breakTimeSec
        self.remainingTimeSec = self.breakTimeSec
    }
}

extension TimerManager {
    enum Mode {
        case focusMode
        case breakMode
        case additionalFocusMode
    }
}

extension TimerManager {
    struct Args {
        let isManualBreakStartEnabled: Bool
        let focusTimeMin: Int
        let breakTimeMin: Int
    }
}
