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
    @StateObject private var viewModel: TimerService // TODO: rename
    @State private var resultFocusTimeSec: Int?
    
    private let focusColor: Color
    private let breakColor: Color

    public init(dependency: Dependency) {
        self.focusColor = dependency.focusColor
        self.breakColor = dependency.breakColor
        
        self._viewModel = StateObject(wrappedValue: .init(
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
                    Text({switch self.viewModel.timerMode {
                        case .focusMode: "Focus Mode"
                        case .breakMode: "Break Mode"
                        case .additionalFocusMode: "Additional Focus Mode"
                    }}())
                }
                
                HStack {
                    Text("Remaining Time")
                    Spacer()
                    Text(remainingTimeString)
                }
                
                HStack {
                    Text("Total Focus Time")
                    Spacer()
                    Text(totalFocusTimeString)
                }
            }
            
            Button {
                Self.hapticFeedback.impactOccurred()
                self.viewModel.tapBreakStartButton()
            } label: {
                Text("Start Break").bold()
            }
            .hidden(startBreakButtonDisabled)
            
            Button {
                Self.hapticFeedback.impactOccurred()
                self.viewModel.tapPlayButton()
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
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 確認アラートを挟む
                    self.viewModel.terminate()
                    self.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Cancel")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 確認アラートを挟む
                    resultFocusTimeSec = viewModel.totalFocusTimeSec
                    viewModel.terminate()

                } label: {
                    Text("Done")
                }
            }
        }
        .navigationDestination(item: $resultFocusTimeSec) {
            TimerRecordView(resultFocusTimeSec: $0)
        }
        .onAppear {
            self.viewModel.onAppear()
        }
    }
}

// MARK: - computed properties
extension TimerView {
    private var modeColor: Color {
        viewModel.timerMode == .focusMode ? focusColor : breakColor
    }
    
    private var trimTo: CGFloat {
        viewModel.timerMode == .breakMode ? CGFloat(1 - (CGFloat(viewModel.remainingTimeSec) / CGFloat(viewModel.maxTimeSec))) : 1
    }
    
    private var trimFrom: CGFloat {
        viewModel.timerMode == .breakMode ? 0 : CGFloat(1 - (CGFloat(viewModel.remainingTimeSec) / CGFloat(viewModel.maxTimeSec)))
    }
    
    private var remainingTimeString: String {
        "\(viewModel.remainingTimeSec / 60):\(String(format: "%02d", viewModel.remainingTimeSec % 60))"
    }
    
    private var totalFocusTimeString: String {
        "\(viewModel.totalFocusTimeSec / 60):\(String(format: "%02d", viewModel.totalFocusTimeSec % 60))"
    }
    
    private var timerButtonSystemName: String {
        viewModel.isRunning ? "pause.fill" : "play.fill"
    }
    
    private var startBreakButtonDisabled: Bool {
        viewModel.timerMode != .additionalFocusMode
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

extension TimerView {
    static let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
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
