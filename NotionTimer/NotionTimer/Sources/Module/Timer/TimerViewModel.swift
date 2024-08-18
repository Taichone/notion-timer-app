//
//  TimerViewModel.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import SwiftUI
import Combine

@Observable
final class TimerViewState {
    var timerCircleColor: Color
    var trimFrom: CGFloat
    var trimTo: CGFloat
    // var modeText: String
    var displayTime: String
    var displayTotalFocusTime: String
    // var startBreakButtonDisabled: Bool
    // var timerButtonSystemName: String // isRunning ? "pause.fill" : "play.fill"
    var timerMode: TimerManager.Mode // 不要
    var isRunning: Bool // 不要
    
    init(timerCircleColor: Color, trimFrom: CGFloat, trimTo: CGFloat, displayTime: String, displayTotalFocusTime: String, timerMode: TimerManager.Mode, isRunning: Bool) {
        self.timerCircleColor = timerCircleColor
        self.trimFrom = trimFrom
        self.trimTo = trimTo
        self.displayTime = displayTime
        self.displayTotalFocusTime = displayTotalFocusTime
        self.timerMode = timerMode
        self.isRunning = isRunning
    }
}

@Observable
final class TimerViewModel {
    private var timerManager: TimerManager
    
    private let focusColor: Color
    private let breakColor: Color
    
    // TODO: コンピューテッドではなく timerManager からのイベント (timerMode, timerStatus の変更時)で更新する
    var timerCircleColor: Color {
        if self.timerMode == .breakMode {
            self.breakColor
        } else {
            self.focusColor
        }
    }
    
    var trimFrom: CGFloat {
        if self.timerMode == .breakMode {
            0
        } else {
            CGFloat(1 - (self.timerManager.remainingTimeSec / self.timerManager.maxTimeSec))
        }
    }
    
    var trimTo: CGFloat {
        if self.timerMode == .breakMode {
            CGFloat(1 - (self.timerManager.remainingTimeSec / self.timerManager.maxTimeSec))
        } else {
            1
        }
    }
    
    var displayTime: String {
        String(format: "%02d:%02d", Int(self.timerManager.remainingTimeSec) / 60, Int(self.timerManager.remainingTimeSec) % 60)
    }
    
    var displayTotalFocusTime: String {
        String(format: "%02d:%02d", Int(self.timerManager.totalFocusTimeSec) / 60, Int(self.timerManager.totalFocusTimeSec) % 60)
    }
    
    // まんまバインディング
    var timerMode: TimerManager.Mode {
        self.timerManager.timerMode
    }
    
    var isRunning: Bool {
        self.timerManager.isRunning
    }
    
    init(timerManager: TimerManager, focusColor: Color, breakColor: Color) {
        self.timerManager = timerManager
        self.focusColor = focusColor
        self.breakColor = breakColor
    }
}

extension TimerViewModel {
    // MARK: User Action
    func tapPlayButton() {
        self.timerManager.isRunning ?
        self.timerManager.pause() : self.timerManager.start()
    }
    
    func tapBreakStartButton() {
        self.timerManager.endExtraFocusAndStartBreak()
    }
}
