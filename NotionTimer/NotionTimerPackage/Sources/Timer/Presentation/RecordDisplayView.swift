//
//  RecordDisplayView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/03.
//

import SwiftUI
import Charts
import Notion

struct RecordDisplayView: View {
    @Environment(NotionService.self) private var notionService
    @State private var records: [RecordEntity] = []
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                Chart {
                    ForEach(records) { record in
                        BarMark(
                            x: .value("Date", record.date, unit: .day),
                            y: .value("Time", record.time)
                        )
                        .foregroundStyle(LinearGradient(
                            gradient: Gradient(
                                colors: record.tags.map { $0.color.color }
                            ),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day))
                }
                .frame(height: 200)
                .padding()
                .frame(minWidth: scrollViewMinWidth)
            }
            .onAppear {
                if let today = records.map({ $0.date }).max() {
                    proxy.scrollTo(today, anchor: .trailing)
                }
            }
            .task {
                do {
                    records = try await notionService.getAllRecords()
                } catch {
                    debugPrint("ERROR: 記録の取得に失敗") // TODO: ハンドリング
                }
            }
        }
    }
    
    private var scrollViewMinWidth: CGFloat {
        let uniqueDates = Set(records.map { record in
            Calendar.current.startOfDay(for: record.date)
        })
        
        return CGFloat(uniqueDates.count * 80)
    }
}
