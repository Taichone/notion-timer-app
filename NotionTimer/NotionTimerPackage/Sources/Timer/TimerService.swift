//
//  TimerViewService.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import SwiftUI
import Combine
import ManagedSettings // TODO: これも ScreenTime に隠蔽したい
import ScreenTime

@MainActor
final class TimerService: ObservableObject {
    // Dependency
    private let isManualBreakStartEnabled: Bool
    private let focusColor: Color
    private let breakColor: Color
    private let focusTimeSec: Int
    private let breakTimeSec: Int
    
    // UI
    @Published var modeColor: Color
    @Published var trimFrom: CGFloat
    @Published var trimTo: CGFloat
    @Published var remainingTimeString: String
    @Published var totalFocusTimeString: String
    @Published var startBreakButtonDisabled: Bool
    @Published var timerButtonSystemName: String
    
    // Screen Time
    private let screenTimeAPI: ScreenTimeAPIProtocol
    private let restrictedApps: Set<ApplicationToken>?
    
    // Timer status
    @Published var timerMode: Mode // @Published いるっけ？
    private var timer: Timer?
    private var remainingTimeSec: Int = 0
    private var maxTimeSec: Int = 0
    private var isRunning = false
    
    // Record
    private var totalFocusTimeSec: Int = 0
    
    init(
        isManualBreakStartEnabled: Bool,
        focusColor: Color,
        breakColor: Color,
        focusTimeMin: Int,
        breakTimeMin: Int,
        screenTimeAPI: ScreenTimeAPIProtocol,
        restrictedApps: Set<ApplicationToken>?
    ) {
        self.focusColor = focusColor
        self.breakColor = breakColor
        self.focusTimeSec = focusTimeMin * 60
        self.breakTimeSec = breakTimeMin * 60
        self.restrictedApps = restrictedApps
        self.screenTimeAPI = screenTimeAPI
        
        setComponents()
    }
}

extension TimerService {
    func tapPlayButton() {
        isRunning ? pause() : start()
    }
    
    func tapBreakStartButton() {
        endAdditionalFocusAndStartBreak()
    }
    
    func terminate() {
        screenTimeAPI.stopAppRestriction()
        
        stopTimer()
        changeToFocusMode()
    }
    
    func tapFinish() {
        // TODO: 合計集中時間を Notion 記録ビューへ渡して遷移
        terminate()
    }
    
    func onAppear() {
        screenTimeAPI.startAppRestriction(apps: restrictedApps)
    }

    // メソッドにする必要なし
    func getTotalFocusTime() -> Int {
        return totalFocusTimeSec
    }
}

extension TimerService {
    func start() {
        isRunning = true
        timerButtonSystemName = "pause.fill"
        
        switch timerMode {
        case .focusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                await self?.tickInFocusMode()
            }
        case .breakMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                await self?.tickInBreakMode()
            }
        case .additionalFocusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                await self?.tickInAdditionalFocusMode()
            }
        }
    }
    
    func pause() {
        stopTimer()
    }
    
    func endAdditionalFocusAndStartBreak() {
        stopTimer()
        changeToBreakMode()
        start()
    }
    
    private func tickInFocusMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
            totalFocusTimeSec += 1
        } else {
            if isManualBreakStartEnabled {
                stopTimer()
                changeToAdditionalFocusMode()
                start()
            } else {
                stopTimer()
                changeToBreakMode()
                start()
            }
        }
        
        setComponents()
    }
    
    private func tickInAdditionalFocusMode() {
        totalFocusTimeSec += 1
    }
    
    private func tickInBreakMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
        } else {
            stopTimer()
            changeToFocusMode()
            start()
        }
        
        setComponents()
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func changeToFocusMode() {
        timerMode = .focusMode
        maxTimeSec = focusTimeSec
        remainingTimeSec = focusTimeSec
        
        setComponents()
    }
    
    private func changeToAdditionalFocusMode() {
        timerMode = .additionalFocusMode
        
        setComponents()
    }
    
    private func changeToBreakMode() {
        timerMode = .breakMode
        maxTimeSec = breakTimeSec
        remainingTimeSec = breakTimeSec
        
        setComponents()
    }
}

extension TimerService {
    func setComponents() {
        modeColor = (timerMode == .focusMode) ? focusColor : breakColor
        remainingTimeString = "\(remainingTimeSec / 60):\(String(format: "%02d", remainingTimeSec % 60))"
        trimFrom = timerMode == .breakMode ? 0 : CGFloat(1 - (CGFloat(remainingTimeSec) / CGFloat(maxTimeSec)))
        trimTo = timerMode == .breakMode ? CGFloat(1 - (CGFloat(remainingTimeSec) / CGFloat(maxTimeSec))) : 1
        startBreakButtonDisabled = timerMode != .additionalFocusMode
        timerButtonSystemName = isRunning ? "play.fill" : "pause.fill"
    }
}

extension TimerService {
    enum Mode {
        case focusMode
        case breakMode
        case additionalFocusMode
    }

    struct Args {
        let isManualBreakStartEnabled: Bool
        let focusTimeMin: Int
        let breakTimeMin: Int
    }
}