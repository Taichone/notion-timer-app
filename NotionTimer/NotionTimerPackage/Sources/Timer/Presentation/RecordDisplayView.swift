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
                        ForEach(record.tags, id: \.id) { tag in
                            BarMark(
                                x: .value("Date", record.date, unit: .day),
                                y: .value("Time", record.time)
                            )
                            .foregroundStyle(tag.color.color)
                            .annotation(position: .overlay) {
                                Text("\(record.time)")
                                    .font(.caption)
                                    .foregroundColor(.white) // 読みやすさのための色調整
                            }
                        }
                    }
                }
                .chartXScale(domain: xScaleDomain)
                .chartYScale(domain: 0...yScaleUpperBound)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) // 日単位の目盛り
                }
                .chartYAxis {
                    AxisMarks() // デフォルトの目盛り
                }
                .frame(height: 300)
                .padding()
                .frame(minWidth: scrollViewMinWidth) // スクロール可能な最小幅
            }
            .onAppear {
                // 表示時に今日の日付にスクロール
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
    
    // スクロール可能な幅を設定
    private var scrollViewMinWidth: CGFloat {
        CGFloat(records.count * 120)
    }
    
    // x軸のスケールドメインを動的に計算
    private var xScaleDomain: ClosedRange<Date> {
        guard let minDate = records.map({ $0.date }).min(),
              let maxDate = records.map({ $0.date }).max() else {
            let now = Date()
            return now...now
        }
        return Calendar.current.date(byAdding: .day, value: -1, to: minDate)!...Calendar.current.date(byAdding: .day, value: 1, to: maxDate)!
    }
    
    // y軸の上限を計算
    private var yScaleUpperBound: Double {
        let maxTime = records.map({ $0.time }).max() ?? 0
        return Double(maxTime) * 1.1 // 上限をデータの最大値 + 10% に設定
    }
}
