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
            // TODO: Label を選択・追加画面の追加
            Text(String(resultFocusTimeSec))
            Button {
                addRecord(
                    taskCategory: .init(name: "test"),
                    time: resultFocusTimeSec
                )
            } label: {
                Text("model に add")
            }
        }
    }
    
    private func addRecord(taskCategory: TaskCategory, time: Int) {
        let fetchDescriptor = FetchDescriptor<Record>()
        do {
            let records = try context.fetch(fetchDescriptor)
            if let record = records.first(where: {
                $0.taskCategory.name == taskCategory.name
            }) {
                record.time += time
            }
            
            let newRecord = Record(taskCategory: taskCategory, time: time)
            context.insert(newRecord)
            try context.save()
        } catch {
            print("データの取得または保存に失敗")
        }
    }
}

#Preview {
    TimerRecordView(resultFocusTimeSec: 3661)
}
