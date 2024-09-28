//
//  TimerViewService.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/16

import SwiftUI
import Combine
import ManagedSettings

@MainActor
final class TimerService: ObservableObject {
    private let timerManager: TimerManager
    
    // UI
    private let focusColor: Color
    private let breakColor: Color
    @Published var modeColor: Color
    @Published var trimFrom: CGFloat
    @Published var trimTo: CGFloat
    @Published var remainingTimeString: String
    @Published var totalFocusTimeString: String
    @Published var timerMode: TimerManager.Mode
    @Published var startBreakButtonDisabled: Bool
    @Published var timerButtonSystemName: String
    
    // Screen Time
    private let screenTimeAPI: ScreenTimeAPIProtocol
    private let restrictedApps: Set<ApplicationToken>?
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    init(
        timerManager: TimerManager,
        focusColor: Color,
        breakColor: Color,
        screenTimeAPI: ScreenTimeAPIProtocol,
        restrictedApps: Set<ApplicationToken>?
    ) {
        self.timerManager = timerManager
        self.focusColor = focusColor
        self.breakColor = breakColor
        self.restrictedApps = restrictedApps
        self.screenTimeAPI = screenTimeAPI
        
        // 初期化
        self.modeColor = timerManager.timerMode == .focusMode ? focusColor : breakColor
        self.trimFrom = timerManager.timerMode == .breakMode ? 0 : CGFloat(1 - (CGFloat(timerManager.remainingTimeSec) / CGFloat(timerManager.maxTimeSec)))
        self.trimTo = timerManager.timerMode == .breakMode ? CGFloat(1 - (CGFloat(timerManager.remainingTimeSec) / CGFloat(timerManager.maxTimeSec))) : 1
        self.remainingTimeString = "\(timerManager.remainingTimeSec / 60):\(String(format: "%02d", timerManager.remainingTimeSec % 60))"
        self.totalFocusTimeString = "\(timerManager.totalFocusTimeSec / 60):\(String(format: "%02d", timerManager.totalFocusTimeSec % 60))"
        self.timerMode = timerManager.timerMode
        self.startBreakButtonDisabled = true
        self.timerButtonSystemName = timerManager.isRunning ? "pause.fill" : "play.fill"
        
        // timerManager 購読
        timerManager.$timerMode
            .sink { [weak self] mode in
                guard let self = self else { return }
                self.modeColor = mode == .focusMode ? self.focusColor : self.breakColor
                self.timerMode = mode
            }
            .store(in: &cancellables)
        
        timerManager.$remainingTimeSec
            .sink { [weak self] remainingTime in
                guard let manager = self?.timerManager else { return }
                self?.remainingTimeString = "\(remainingTime / 60):\(String(format: "%02d", remainingTime % 60))"
                self?.trimFrom = self?.timerMode == .breakMode ? 0 : CGFloat(1 - (CGFloat(remainingTime) / CGFloat(manager.maxTimeSec)))
                self?.trimTo = self?.timerMode == .breakMode ? CGFloat(1 - (CGFloat(remainingTime) / CGFloat(manager.maxTimeSec))) : 1
                self?.startBreakButtonDisabled = self?.timerMode != .additionalFocusMode
            }
            .store(in: &cancellables)
        
        timerManager.$totalFocusTimeSec
            .sink { [weak self] totalFocusTime in
                self?.totalFocusTimeString = "\(totalFocusTime / 60):\(String(format: "%02d", totalFocusTime % 60))"
            }
            .store(in: &cancellables)
        
        timerManager.$isRunning
            .sink { [weak self] isRunning in
                self?.timerButtonSystemName = isRunning ? "pause.fill" : "play.fill"
            }
            .store(in: &cancellables)
    }
}

extension TimerService {
    func tapPlayButton() {
        self.timerManager.isRunning ?
        self.timerManager.pause() : self.timerManager.start()
    }
    
    func tapBreakStartButton() {
        self.timerManager.endAdditionalFocusAndStartBreak()
    }
    
    func terminate() {
        self.screenTimeAPI.stopAppRestriction()
        self.timerManager.terminate()
    }
    
    func tapFinish() {
        // TODO: 合計集中時間を Notion 記録ビューへ渡して遷移
        self.terminate()
    }
    
    func onAppear() {
        self.screenTimeAPI.startAppRestriction(apps: self.restrictedApps)
    }

    func getTotalFocusTime() -> Int {
        return timerManager.totalFocusTimeSec
    }
}

protocol ScreenTimeAPIProtocol {
    func authorize() async
    func startAppRestriction(apps: Set<ApplicationToken>?)
    func stopAppRestriction()
}
