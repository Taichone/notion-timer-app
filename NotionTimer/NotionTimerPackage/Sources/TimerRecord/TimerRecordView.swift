//
//  TimerRecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI
import SwiftData
import Record

public struct TimerRecordView: View {
    @Environment(\.modelContext) private var context
    public let resultFocusTimeSec: Int
    
    public init(resultFocusTimeSec: Int) {
        self.resultFocusTimeSec = resultFocusTimeSec
    }
    
    public var body: some View {
        VStack {
            // TODO: Category を選択・追加画面の追加
            
            Text(String(resultFocusTimeSec))
            Button {
                let data = TaskCategoryRecord(category: TaskCategory(name: "test"), time: resultFocusTimeSec)
                context.insert(data)
            } label: {
                Text("model に add")
            }
        }
    }
}

#Preview {
    TimerRecordView(resultFocusTimeSec: 3661)
}
