//
//  TimerViewService.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import SwiftUI
import Combine
import ManagedSettings // TODO: これも ScreenTime に隠蔽したい（Set<ApplicationToken>? を ScreenTime.Xxx? のように）
import ScreenTime

@MainActor
final class TimerService: ObservableObject {
    // Dependency
    private let isManualBreakStartEnabled: Bool
    private let focusTimeSec: Int
    private let breakTimeSec: Int
    private let screenTimeAPI: ScreenTimeAPIProtocol
    private let restrictedApps: Set<ApplicationToken>?
    
    // Timer status
    private var timer: Timer?
    @Published var timerMode: Mode
    @Published var maxTimeSec: Int = 0
    @Published var remainingTimeSec: Int = 0
    @Published var isRunning = false
    @Published var totalFocusTimeSec: Int = 0
    
    init(
        isManualBreakStartEnabled: Bool,
        focusTimeMin: Int,
        breakTimeMin: Int,
        screenTimeAPI: ScreenTimeAPIProtocol,
        restrictedApps: Set<ApplicationToken>?
    ) {
        self.isManualBreakStartEnabled = isManualBreakStartEnabled
        self.focusTimeSec = focusTimeMin * 60
        self.breakTimeSec = breakTimeMin * 60
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
    
    // TODO: 合計集中時間を Notion 記録ビューへ渡して遷移
    func tapFinish() {
        terminate()
    }
    
    func onAppear() {
        screenTimeAPI.startAppRestriction(apps: restrictedApps)
    }
}

extension TimerService {
    private func endAdditionalFocusAndStartBreak() {
        stopTimer()
        changeToBreakMode()
        startTimer()
    }
    
    private func tickInFocusMode() {
        if remainingTimeSec > 0 {
            remainingTimeSec -= 1
            totalFocusTimeSec += 1
        } else {
            stopTimer()
            isManualBreakStartEnabled ? changeToAdditionalFocusMode() : changeToBreakMode()
            startTimer()
        }
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
            startTimer()
        }
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
    }
    
    private func changeToAdditionalFocusMode() {
        timerMode = .additionalFocusMode
    }
    
    private func changeToBreakMode() {
        timerMode = .breakMode
        maxTimeSec = breakTimeSec
        remainingTimeSec = breakTimeSec
    }
    
    private func startTimer() {
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
