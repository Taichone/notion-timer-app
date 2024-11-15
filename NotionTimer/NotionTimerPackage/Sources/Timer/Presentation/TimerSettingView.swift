//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import ScreenTime
import Common

enum TimerNavigationPath {
    case setting, timer, record
}

enum TimerSettingSheetType: String, Identifiable {
    case focusTimePicker
    case breakTimePicker
    
    var id: String { self.rawValue }
    var title: String {
        switch self {
        case .focusTimePicker:
            String(moduleLocalized: "focus-time-picker-title")
        case .breakTimePicker:
            String(moduleLocalized: "break-time-picker-title")
        }
    }
}

public struct TimerSettingView: View {
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
    @State private var restrictedApps = ScreenTime.appSelection()
    private let screenTimeAPI = ScreenTimeAPIClient.shared
    
    public init() {}
    
    public var body: some View {
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
                Toggle(isOn: self.$isBreakEndSoundEnabled) {
                    Text(String(moduleLocalized: "enable-sound-at-break-end"))
                }
                Toggle(isOn: self.$isManualBreakStartEnabled) {
                    Text(String(moduleLocalized: "start-break-time-manually"))
                }
                ColorPicker(String(moduleLocalized: "focus-time-color"), selection: self.$focusColor)
                ColorPicker(String(moduleLocalized: "break-time-color"), selection: self.$breakColor)
            }
            
            Button {
                self.isFamilyActivityPickerPresented = true
            } label: {
                Text(String(moduleLocalized: "select-apps-to-restrict"))
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle(String(moduleLocalized: "timer-setting"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TimerView(dependency: .init(
                    isBreakEndSoundEnabled: self.isBreakEndSoundEnabled,
                    isManualBreakStartEnabled: self.isManualBreakStartEnabled,
                    focusTimeSec: self.focusTimeSec,
                    breakTimeSec: self.breakTimeSec,
                    focusColor: self.focusColor,
                    breakColor: self.breakColor,
                    restrictedApps: self.restrictedApps.applicationTokens
                ))) {
                    Text(String(moduleLocalized: "ok"))
                }
            }
        }
        .familyActivityPicker(
            isPresented: self.$isFamilyActivityPickerPresented,
            selection: self.$restrictedApps
        )
        .task {
            self.screenTimeAPI.stopAppRestriction()
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
