//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct SetTimerView: View {
    @State private var isBreakEndSoundEnabled = false
    @State private var isManualBreakStartEnabled = true
    @State private var focusTimeMinutes = 25
    @State private var breakTimeMinutes = 5
    @State private var focusColor = Color.mint
    @State private var breakColor = Color.green
    @State private var taskCategory = TaskCategory(name: "Swift")
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // TODO: TagSlectionView に遷移
                    Picker("Task Category", selection: self.$taskCategory) {
                        ForEach(TaskCategory.mockList) {
                            Text($0.name)
                        }
                    }.pickerStyle(.navigationLink)
                }
                
                Section {
                    Picker("Focus Time", selection: self.$focusTimeMinutes) {
                        ForEach(1..<91) { minute in
                            (Text("\(minute) ") + Text("min")).tag(minute)
                        }
                    }.pickerStyle(.navigationLink)
                    Picker("Break Time", selection: self.$breakTimeMinutes) {
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
                NavigationLink(destination: TimerView()) {
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
