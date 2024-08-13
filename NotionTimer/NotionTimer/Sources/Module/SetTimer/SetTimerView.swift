//
//  SetTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct SetTimerView: View {
    @State private var isBreakEndAlarmEnabled = false
    @State private var isManualBreakStartEnabled = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Notion Settings") {
                    // TODO: TagSlectionView に遷移
                    Text("タグ >")
                }
                
                Section("Timer Settings") {
                    // TODO: TimeSelectionView に遷移
                    Text("集中時間 >")
                    // TODO: TimeSelectionView に遷移
                    Text("休憩時間 >")
                    Toggle(isOn: self.$isBreakEndAlarmEnabled) {
                        Text("Trigger an alarm at break end")
                    }
                    Toggle(isOn: self.$isManualBreakStartEnabled) {
                        Text("Start break time manually")
                    }
                }
                
                Button {
                    // TODO: TimerView に遷移して開始
                    print("===Start Timer")
                } label: {
                    Text("Start Timer").bold()
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
