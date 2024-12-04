//
//  RecordDisplayView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/03.
//

import SwiftUI
import Charts
import Notion
import Common

struct RecordDisplayView: View {
    @Environment(NotionService.self) private var notionService
    @State private var records: [RecordEntity] = []
    @State private var isLoading = true
    private let chartViewID = UUID()
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    Chart {
                        ForEach(records) { record in
                            BarMark(
                                x: .value("Date", record.date, unit: .day),
                                y: .value("Time", record.time)
                            )
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: tagColors(from: record)),
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
                    .frame(width: chartViewWidth)
                    .id(chartViewID)
                }
                .task {
                    await fetchAllRecords()
                    proxy.scrollTo(chartViewID, anchor: .trailing) // 右端へスクロール
                }
            }
            
            CommonLoadingView()
                .hidden(!isLoading)
        }
    }
    
    private var chartViewWidth: CGFloat {
        let uniqueDates = Set(records.map { record in
            Calendar.current.startOfDay(for: record.date)
        })
        
        return CGFloat(uniqueDates.count * 100)
    }
    
    private func tagColors(from record: RecordEntity) -> [Color] {
        var colors = record.tags.map { $0.color.color }
        if colors.isEmpty {
            colors.append(TagEntity.Color.default.color)
        }
        return colors
    }
    
    private func fetchAllRecords() async {
        do {
            isLoading = true
            records = try await notionService.getAllRecords()
            isLoading = false
        } catch {
            debugPrint("ERROR: 記録の取得に失敗") // TODO: ハンドリング
        }
    }
}
