//
//  TimerViewModel.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import SwiftUI
import Combine

@Observable
class TimerViewModel {
    private var timerManager: TimerManager
    
    private let focusColor: Color
    private let breakColor: Color
    
    // TODO: コンピューテッドではなく timerManager からのイベント (timerMode, timerStatus の変更時)で更新する
    var timerCircleColor: Color {
        if timerMode == .breakMode {
            self.breakColor
        } else {
            self.focusColor
        }
    }
    
    var trimFrom: CGFloat {
        if timerMode == .breakMode {
            0
        } else {
            CGFloat(1 - (remainingTimeSec / timerManager.maxTimeSec))
        }
    }
    
    var trimTo: CGFloat {
        if timerMode == .breakMode {
            CGFloat(1 - (remainingTimeSec / timerManager.maxTimeSec))
        } else {
            1
        }
    }
    
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
    
    init(timerManager: TimerManager, focusColor: Color, breakColor: Color) {
        self.timerManager = timerManager
        self.focusColor = focusColor
        self.breakColor = breakColor
    }
}

extension TimerViewModel {
    // MARK: User Action
    func tapPlayButton() {
        self.timerManager.timerStatus == .running ?
        self.timerManager.pause() : self.timerManager.start()
    }
    
    func tapBreakStartButton() {
        self.timerManager.endExtraFocusAndStartBreak()
    }
}
