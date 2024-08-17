//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct SetTimerView: View {
    @AppStorage(wrappedValue: false, "isBreakEndSoundEnabled")
    private var isBreakEndSoundEnabled
    @AppStorage(wrappedValue: true, "isManualBreakStartEnabled")
    private var isManualBreakStartEnabled
    @AppStorage(wrappedValue: 25, "focusTimeMin")
    private var focusTimeMin
    @AppStorage(wrappedValue: 5, "breakTimeMin")
    private var breakTimeMin
    
    @State private var focusColor = Color.mint
    @State private var breakColor = Color.blue
    @State private var taskCategory = TaskCategory.mockList.first
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // TODO: この責務は Timer には含めない
                    Picker("Task Category", selection: self.$taskCategory) {
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
                        Text("Enable sound at break end")
                    }
                    Toggle(isOn: self.$isManualBreakStartEnabled) {
                        Text("Start break time manually")
                    }
                }
                Section {
                    ColorPicker("Focus Time Color", selection: self.$focusColor)
                    ColorPicker("Break Time Color", selection: self.$breakColor)
                }
                NavigationLink(destination: TimerView(args: .init(
                    isBreakEndSoundEnabled: self.isBreakEndSoundEnabled,
                    isManualBreakStartEnabled: self.isManualBreakStartEnabled,
                    focusTimeMin: self.focusTimeMin,
                    breakTimeMin: self.focusTimeMin,
                    focusColor: self.focusColor,
                    breakColor: self.breakColor
                ))) {
                    Text("Start Timer!").foregroundStyle(.blue).bold()
                }
            }
            .navigationTitle("Set Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // TODO: 設定に遷移（制限するアプリの設定, Notion アカウント関連など？）
                        print("===Setting")
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    SetTimerView()
}
