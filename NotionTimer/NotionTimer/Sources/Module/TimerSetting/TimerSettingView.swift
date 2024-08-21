//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct TimerSettingView: View {
    @AppStorage(wrappedValue: false, "isBreakEndSoundEnabled") private var isBreakEndSoundEnabled
    @AppStorage(wrappedValue: true, "isManualBreakStartEnabled") private var isManualBreakStartEnabled
    @AppStorage(wrappedValue: 25, "focusTimeMin") private var focusTimeMin
    @AppStorage(wrappedValue: 5, "breakTimeMin") private var breakTimeMin
    
    @State private var focusColor = Color.mint
    @State private var breakColor = Color.blue
    @State private var taskCategory = TaskCategory.mockList.first
    
    // Screen Time
    @State private var restrictedApps = FamilyActivitySelection()
    @State private var isFamilyActivityPickerPresented = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // TODO: この責務は Timer には含めない
                    Picker("Task", selection: self.$taskCategory) {
                        ForEach(TaskCategory.mockList, id: \.id) { category in
                            Text(category.name).tag(category as TaskCategory?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section {
                    Picker("Focus Time", selection: self.$focusTimeMin) {
                        ForEach(1..<91) { minute in
                            (Text("\(minute) ") + Text("min")).tag(minute)
                        }
                    }.pickerStyle(.navigationLink)
                    Picker("Break Time", selection: self.$breakTimeMin) {
                        ForEach(1..<91) { minute in
                            (Text("\(minute) ") + Text("min")).tag(minute)
                        }
                    }.pickerStyle(.navigationLink)
                }
                
                Section {
                    Toggle(isOn: self.$isBreakEndSoundEnabled) {
                        Text("Enable Sound At Break End")
                    }
                    Toggle(isOn: self.$isManualBreakStartEnabled) {
                        Text("Start Break Time Manually")
                    }
                    ColorPicker("Focus Time Color", selection: self.$focusColor)
                    ColorPicker("Break Time Color", selection: self.$breakColor)
                }
                
                Button {
                    self.isFamilyActivityPickerPresented = true
                } label: {
                    Text("Select Apps to Restrict")
                }
            }
            .navigationTitle("Timer Setting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        print("Tapped Setting Button")
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TimerView(args: .init(
                        isBreakEndSoundEnabled: self.isBreakEndSoundEnabled,
                        isManualBreakStartEnabled: self.isManualBreakStartEnabled,
                        focusTimeMin: self.focusTimeMin,
                        breakTimeMin: self.focusTimeMin,
                        focusColor: self.focusColor,
                        breakColor: self.breakColor
                    ))) {
                        Text("Start")
                    }
                }
            }
            .familyActivityPicker(
                isPresented: self.$isFamilyActivityPickerPresented,
                selection: self.$restrictedApps
            )
        }
    }
}

#Preview {
    TimerSettingView()
}
