//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import ManagedSettings
import ScreenTime
import TimerRecord
import ViewCommon

public struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var timerService: TimerService // TODO: rename
    @State private var resultFocusTimeSec: Int?
    
    private let focusColor: Color
    private let breakColor: Color

    public init(dependency: Dependency) {
        self.focusColor = dependency.focusColor
        self.breakColor = dependency.breakColor
        
        self._timerService = StateObject(wrappedValue: .init(
            isManualBreakStartEnabled: dependency.isManualBreakStartEnabled,
            focusTimeMin: dependency.focusTimeMin,
            breakTimeMin: dependency.breakTimeMin,
            screenTimeAPI: ScreenTimeAPI.shared,
            restrictedApps: dependency.restrictedApps
        ))
    }
    
    public var body: some View {
        VStack {
            ZStack {
                TimerCircle(color: Color(.gray).opacity(0.1))
                TimerCircle(
                    color: modeColor,
                    trimFrom: trimFrom,
                    trimTo: trimTo
                )
                .animation(.smooth, value: trimFrom)
                .animation(.smooth, value: trimTo)
                .rotationEffect(Angle(degrees: -90))
                .shadow(radius: 10)
            }
            
            List {
                HStack {
                    Text(timerModeName)
                }
                
                HStack {
                    Text(String(moduleLocalized: "remaining-time"))
                    Spacer()
                    Text(remainingTimeString)
                }
                
                HStack {
                    Text(String(moduleLocalized: "total-focus-time"))
                    Spacer()
                    Text(totalFocusTimeString)
                }
                .foregroundStyle(totalFocusTimeDisplayColor)
            }
            
            Button {
                ExternalOutput.tapticFeedback()
                self.timerService.tapBreakStartButton()
            } label: {
                Text(String(moduleLocalized: "start-break")).bold()
            }
            .hidden(startBreakButtonDisabled)
            
            Button {
                ExternalOutput.tapticFeedback()
                self.timerService.tapPlayButton()
            } label: {
                Image(systemName: timerButtonSystemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground)) // List 背景色に合わせる
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String(moduleLocalized: "timer"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 確認アラートを挟む
                    self.timerService.terminate()
                    self.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(String(moduleLocalized: "cancel"))
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 確認アラートを挟む
                    resultFocusTimeSec = timerService.totalFocusTimeSec
                    timerService.terminate()

                } label: {
                    Text(String(moduleLocalized: "done"))
                }
            }
        }
        .navigationDestination(item: $resultFocusTimeSec) {
            TimerRecordView(resultFocusTimeSec: $0)
        }
        .onAppear {
            self.timerService.onAppear()
        }
    }
}

// MARK: - computed properties
extension TimerView {
    private var modeColor: Color {
        timerService.timerMode == .focusMode ? focusColor : breakColor
    }
    
    private var trimTo: CGFloat {
        timerService.timerMode == .breakMode ? CGFloat(1 - (CGFloat(timerService.remainingTimeSec) / CGFloat(timerService.maxTimeSec))) : 1
    }
    
    private var trimFrom: CGFloat {
        timerService.timerMode == .breakMode ? 0 : CGFloat(1 - (CGFloat(timerService.remainingTimeSec) / CGFloat(timerService.maxTimeSec)))
    }
    
    private var remainingTimeString: String {
        "\(timerService.remainingTimeSec / 60):\(String(format: "%02d", timerService.remainingTimeSec % 60))"
    }
    
    private var totalFocusTimeString: String {
        "\(timerService.totalFocusTimeSec / 60):\(String(format: "%02d", timerService.totalFocusTimeSec % 60))"
    }
    
    private var timerButtonSystemName: String {
        timerService.isRunning ? "pause.fill" : "play.fill"
    }
    
    private var startBreakButtonDisabled: Bool {
        timerService.timerMode != .additionalFocusMode
    }
    
    private var totalFocusTimeDisplayColor: Color {
        timerService.timerMode == .additionalFocusMode ? focusColor : Color(.label)
    }
    
    private var timerModeName: String {
        switch timerService.timerMode {
        case .focusMode: String(moduleLocalized: "focus-mode")
        case .breakMode: String(moduleLocalized: "break-mode")
        case .additionalFocusMode: String(moduleLocalized: "additional-focus-mode")
        }
    }
}

extension TimerView {
    public struct Dependency { // TODO: rename to Dependency
        let isBreakEndSoundEnabled: Bool
        let isManualBreakStartEnabled: Bool
        let focusTimeMin: Int
        let breakTimeMin: Int
        let focusColor: Color
        let breakColor: Color
        let restrictedApps: Set<ApplicationToken>?
        
        public init(
            isBreakEndSoundEnabled: Bool,
            isManualBreakStartEnabled: Bool,
            focusTimeMin: Int,
            breakTimeMin: Int,
            focusColor: Color,
            breakColor: Color,
            restrictedApps: Set<ApplicationToken>?
        ) {
            self.isBreakEndSoundEnabled = isBreakEndSoundEnabled
            self.isManualBreakStartEnabled = isManualBreakStartEnabled
            self.focusTimeMin = focusTimeMin
            self.breakTimeMin = breakTimeMin
            self.focusColor = focusColor
            self.breakColor = breakColor
            self.restrictedApps = restrictedApps
        }
    }
}

#Preview {
    NavigationStack {
        TimerView(dependency: .init(
            isBreakEndSoundEnabled: true,
            isManualBreakStartEnabled: true,
            focusTimeMin: 25,
            breakTimeMin: 5,
            focusColor: .mint,
            breakColor: .pink,
            restrictedApps: nil
        ))
    }
}
