//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import ScreenTime

enum TimerSettingSheetType: String, Identifiable {
    case focusTimePicker
    case breakTimePicker
    
    var id: String { rawValue }
    var title: String {
        switch self {
        case .focusTimePicker:
            String(moduleLocalized: "focus-time-picker-title")
        case .breakTimePicker:
            String(moduleLocalized: "break-time-picker-title")
        }
    }
}

struct TimerSettingView: View {
    // Router
    @EnvironmentObject var router: NavigationRouter
    
    // Timer
    @AppStorage(wrappedValue: 1500, "focusTimeSec") private var focusTimeSec
    @AppStorage(wrappedValue: 300, "breakTimeSec") private var breakTimeSec
    @State private var sheetType: TimerSettingSheetType?
    
    // Color
    @AppStorage(wrappedValue: false, "isBreakEndSoundEnabled") private var isBreakEndSoundEnabled
    @AppStorage(wrappedValue: true, "isManualBreakStartEnabled") private var isManualBreakStartEnabled
    @State private var focusColor = Color.mint
    @State private var breakColor = Color.blue
    
    // Screen Time
    @State private var isFamilyActivityPickerPresented = false
    @State private var restrictedApps = ScreenTimeClient.appSelection
    private let screenTimeClient = ScreenTimeClient.liveValue
    
    init() {}
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text(String(moduleLocalized: "focus-time"))
                    Spacer()
                    Button {
                        sheetType = .focusTimePicker
                    } label: {
                        Text(String(focusTimeString))
                    }
                }
                
                HStack {
                    Text(String(moduleLocalized: "break-time"))
                    Spacer()
                    Button {
                        sheetType = .breakTimePicker
                    } label: {
                        Text(String(breakTimeString))
                    }
                }
            }
            
            Section {
                Toggle(isOn: $isBreakEndSoundEnabled) {
                    Text(String(moduleLocalized: "enable-sound-at-break-end"))
                }
                Toggle(isOn: $isManualBreakStartEnabled) {
                    Text(String(moduleLocalized: "start-break-time-manually"))
                }
                ColorPicker(String(moduleLocalized: "focus-time-color"), selection: $focusColor)
                ColorPicker(String(moduleLocalized: "break-time-color"), selection: $breakColor)
            }
            
            Button {
                isFamilyActivityPickerPresented = true
            } label: {
                Text(String(moduleLocalized: "select-apps-to-restrict"))
            }
        }
        .navigationTitle(String(moduleLocalized: "timer-setting"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.items.append(.timer(dependency: .init(
                        isBreakEndSoundEnabled: isBreakEndSoundEnabled,
                        isManualBreakStartEnabled: isManualBreakStartEnabled,
                        focusTimeSec: focusTimeSec,
                        breakTimeSec: breakTimeSec,
                        focusColor: focusColor,
                        breakColor: breakColor,
                        restrictedApps: restrictedApps.applicationTokens
                    )))
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
            }
        }
        .familyActivityPicker(
            isPresented: $isFamilyActivityPickerPresented,
            selection: $restrictedApps
        )
        .task {
            screenTimeClient.stopAppRestriction()
        }
        .sheet(item: $sheetType) { type in
            switch type {
            case .focusTimePicker:
                TimePicker(sec: $focusTimeSec, title: type.title)
                    .presentationDetents([.medium])
            case .breakTimePicker:
                TimePicker(sec: $breakTimeSec, title: type.title)
                    .presentationDetents([.medium])
            }
        }
    }
}

extension TimerSettingView {
    private var focusTimeString: String {
        "\(focusTimeSec / 60):\(String(format: "%02d", focusTimeSec % 60))"
    }
    
    private var breakTimeString: String {
        "\(breakTimeSec / 60):\(String(format: "%02d", breakTimeSec % 60))"
    }
}

#Preview {
    TimerSettingView()
}
