//
//  TimePicker.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/14.
//

import SwiftUI

struct TimePicker: View {
    @Binding var sec: Int
    @State private var minSelection: Int
    @State private var secSelection: Int
    @Environment(\.dismiss) private var dismiss
    private let navigationTitle: String
    
    init(sec: Binding<Int>, title: String = "") {
        self._sec = sec
        self.minSelection = sec.wrappedValue / 60
        self.secSelection = sec.wrappedValue % 60
        self.navigationTitle = title
    }
    
    var body: some View {
        NavigationStack {
            HStack {
                Picker(String(moduleLocalized: "min"), selection: $minSelection) {
                    ForEach(0..<91) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                .clipped()
                
                Text(":")
                
                Picker(String(moduleLocalized: "sec"), selection: $secSelection) {
                    ForEach(0..<60) { sec in
                        Text("\(sec)").tag(sec)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
                .clipped()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(String(moduleLocalized: "cancel"))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        sec = minSelection * 60 + secSelection
                        dismiss()
                    } label: {
                        Text(String(moduleLocalized: "ok"))
                    }
                    .disabled(minSelection == 0 && secSelection == 0)
                }
            }
        }
    }
}

#Preview {
    TimePickerViewWrapper()
}

fileprivate struct TimePickerViewWrapper: View {
    @State private var sec = 0
    @State private var isShowSheet = false
    
    var body: some View {
        Button {
            isShowSheet = true
        } label: {
            Circle()
        }
        .sheet(isPresented: $isShowSheet) {
            TimePicker(sec: $sec, title: "TimePickerView")
                .presentationDetents([.medium])
        }
    }
}
