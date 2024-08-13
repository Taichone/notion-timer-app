//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct TimerView: View {
    // TODO: データ繋ぎこみ
    @State private var isFocusMode = true
    @State private var duration = 240.0
    @State private var maxFocusTimeSec = 300.0
    @State private var maxBreakTimeSec = 180.0
    private var focusColor = Color(.blue)
    private var breakColor = Color(.green)
    
    var body: some View {
        VStack {
            ZStack {
                TimerCircle(color: Color(.gray).opacity(0.1))
                TimerCircle(
                    color: self.isFocusMode ? self.focusColor: self.breakColor,
                    trimFrom: CGFloat(self.isFocusMode ? 1 - self.duration / Double(self.maxFocusTimeSec) : 0),
                    trimTo: CGFloat(self.isFocusMode ? 1 : 1 - (self.duration / Double(self.maxBreakTimeSec)))
                )
                .rotationEffect(Angle(degrees: -90))
                .shadow(radius: 10)
            }
            List {
                Section {
                    Text("Mode: ") + Text(self.isFocusMode ? "Focus" : "Break")
                    Text("Remaining Time: ") + Text("4 min")
                    Text("Total Focus Time: ") + Text("90 min")
                }
                
                Button {
                    print("Timer Pause / Resume")
                } label: {
                    Text("Pause / Resume").bold()
                }
            }
        }
        .navigationTitle("Timer")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AfterTimerView()) {
                    Text("Done")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TimerView()
    }
}
