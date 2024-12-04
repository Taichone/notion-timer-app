//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import ManagedSettings
import ScreenTime

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var router: NavigationRouter
    @StateObject private var timerService: TimerService
    
    private let focusColor: Color
    private let breakColor: Color
    
    init(dependency: Dependency) {
        self.focusColor = dependency.focusColor
        self.breakColor = dependency.breakColor
        
        self._timerService = StateObject(wrappedValue: .init(
            isManualBreakStartEnabled: dependency.isManualBreakStartEnabled,
            focusTimeSec: dependency.focusTimeSec,
            breakTimeSec: dependency.breakTimeSec,
            screenTimeAPI: ScreenTimeAPIClient.shared,
            restrictedApps: dependency.restrictedApps
        ))
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(timerModeName)
                }
                
                Divider()
                
                HStack {
                    Text(String(moduleLocalized: "remaining-time"))
                    Spacer()
                    Text(remainingTimeString)
                }
                
                Divider()
                
                HStack {
                    Text(String(moduleLocalized: "total-focus-time"))
                    Spacer()
                    Text(totalFocusTimeString)
                }
            }
            .padding()
            .background {
                GlassmorphismRoundedRectangle()
            }
            
            Spacer()
            
            ZStack {
                TimerCircle(color: Color(.secondarySystemBackground))
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
            
            Spacer()
            
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
        .padding()
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
                    router.items.append(.timerRecord(dependency: .init(
                        resultFocusTimeSec: timerService.totalFocusTimeSec
                    )))
                    
                    timerService.terminate()
                    
                } label: {
                    Text(String(moduleLocalized: "done"))
                }
            }
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
    struct Dependency: Hashable {
        let isBreakEndSoundEnabled: Bool
        let isManualBreakStartEnabled: Bool
        let focusTimeSec: Int
        let breakTimeSec: Int
        let focusColor: Color
        let breakColor: Color
        let restrictedApps: Set<ApplicationToken>?
    }
}

#Preview {
    NavigationStack {
        TimerView(dependency: .init(
            isBreakEndSoundEnabled: true,
            isManualBreakStartEnabled: true,
            focusTimeSec: 1500,
            breakTimeSec: 300,
            focusColor: .mint,
            breakColor: .pink,
            restrictedApps: nil
        ))
    }
}
