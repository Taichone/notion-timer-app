//
//  TimerViewService.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import Foundation
import ManagedSettings // TODO: これも ScreenTime に隠蔽したい（Set<ApplicationToken>? を ScreenTime.Xxx? のように）
import ScreenTime

// TODO: Observable を積極検討
@MainActor
public final class TimerService: ObservableObject {
    // Dependency
    let isManualBreakStartEnabled: Bool
    let focusTimeSec: Int
    let breakTimeSec: Int
    let screenTimeAPI: ScreenTimeAPIProtocol
    let restrictedApps: Set<ApplicationToken>?
    
    // Timer status
    var timer: Timer?
    @Published var timerMode: Mode
    @Published var maxTimeSec: Int = 0
    @Published var remainingTimeSec: Int = 0
    @Published var isRunning = false
    @Published var totalFocusTimeSec: Int = 0
    
    init(
        isManualBreakStartEnabled: Bool,
        focusTimeSec: Int,
        breakTimeSec: Int,
        screenTimeAPI: ScreenTimeAPIProtocol = ScreenTimeAPIClient.shared,
        restrictedApps: Set<ApplicationToken>? = nil
    ) {
        self.isManualBreakStartEnabled = isManualBreakStartEnabled
        self.focusTimeSec = focusTimeSec
        self.breakTimeSec = breakTimeSec
        self.screenTimeAPI = screenTimeAPI
        self.restrictedApps = restrictedApps
        
        // 集中時間から開始
        timerMode = .focusMode
        maxTimeSec = focusTimeSec
        remainingTimeSec = focusTimeSec
    }
}

extension TimerService {
    func tapPlayButton() {
        isRunning ? stopTimer() : startTimer()
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
        terminate()
    }
    
    func onAppear() {
        screenTimeAPI.startAppRestriction(apps: restrictedApps)
    }
}

extension TimerService {
    func endAdditionalFocusAndStartBreak() {
        stopTimer()
        changeToBreakMode()
        startTimer()
    }
    
    func tickInFocusMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
            totalFocusTimeSec += 1
        } else {
            stopTimer()
            isManualBreakStartEnabled ? changeToAdditionalFocusMode() : changeToBreakMode()
            startTimer()
        }
    }
    
    func tickInAdditionalFocusMode() {
        totalFocusTimeSec += 1
    }
    
    func tickInBreakMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
        } else {
            stopTimer()
            changeToFocusMode()
            startTimer()
        }
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func changeToFocusMode() {
        timerMode = .focusMode
        maxTimeSec = focusTimeSec
        remainingTimeSec = focusTimeSec
    }
    
    func changeToAdditionalFocusMode() {
        timerMode = .additionalFocusMode
    }
    
    func changeToBreakMode() {
        timerMode = .breakMode
        maxTimeSec = breakTimeSec
        remainingTimeSec = breakTimeSec
    }
    
    func startTimer() {
        isRunning = true
        
        switch timerMode {
        case .focusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { await self?.tickInFocusMode() }
            }
        case .breakMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { await self?.tickInBreakMode() }
            }
        case .additionalFocusMode:
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { await self?.tickInAdditionalFocusMode() }
            }
        }
    }
}

extension TimerService {
    enum Mode {
        case focusMode
        case breakMode
        case additionalFocusMode
    }
}
