//
//  TimerRecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI

public struct TimerRecordView: View {
    public let resultFocusTimeSec: Int
    
    public init(resultFocusTimeSec: Int) {
        self.resultFocusTimeSec = resultFocusTimeSec
    }
    
    public var body: some View {
        VStack {
            // TODO: Label を選択・追加画面の追加、Notion DB に追加
            Text(String(resultFocusTimeSec))
            Button {
                print("Notion DB に記録（仮）")
            } label: {
                Text("Notion DB に記録 (仮)")
            }
        }
    }
}

#Preview {
    TimerRecordView(resultFocusTimeSec: 3661)
}
