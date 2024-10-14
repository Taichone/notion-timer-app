//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import ScreenTime
import Timer

enum TimerNavigationPath {
    case setting, timer, record
}

public struct TimerSettingView: View {
    @AppStorage(wrappedValue: false, "isBreakEndSoundEnabled") private var isBreakEndSoundEnabled
    @AppStorage(wrappedValue: true, "isManualBreakStartEnabled") private var isManualBreakStartEnabled
    @AppStorage(wrappedValue: 25, "focusTimeMin") private var focusTimeMin
    @AppStorage(wrappedValue: 5, "breakTimeMin") private var breakTimeMin

    @State private var focusColor = Color.mint
    @State private var breakColor = Color.blue

    // Screen Time
    @State private var isFamilyActivityPickerPresented = false
    @State private var restrictedApps = ScreenTime.appSelection()
    private let screenTimeAPI = ScreenTimeAPI.shared
    
    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(moduleLocalized: "focus-time"), selection: self.$focusTimeMin) {
                        ForEach(1..<91) { minute in
                            (Text("\(minute) ") + Text(String(moduleLocalized: "min"))).tag(minute)
                        }
                    }.pickerStyle(.navigationLink)
                    Picker(String(moduleLocalized: "break-time"), selection: self.$breakTimeMin) {
                        ForEach(1..<91) { minute in
                            (Text("\(minute) ") + Text(String(localized: "min", bundle: .module))).tag(minute)
                        }
                    }.pickerStyle(.navigationLink)
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
            .navigationTitle(String(moduleLocalized: "timer-setting"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        print("Tapped Setting Button")
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: TimerView(dependency: .init(
                        isBreakEndSoundEnabled: self.isBreakEndSoundEnabled,
                        isManualBreakStartEnabled: self.isManualBreakStartEnabled,
                        focusTimeMin: self.focusTimeMin,
                        breakTimeMin: self.focusTimeMin,
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
        }
    }
}

#Preview {
    TimerSettingView()
}
