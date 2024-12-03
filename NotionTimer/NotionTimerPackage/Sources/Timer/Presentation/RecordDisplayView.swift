//
//  RecordDisplayView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/03.
//

import SwiftUI
import Notion

struct RecordDisplayView: View {
    @Environment(NotionService.self) private var notionService
    @State private var records: [RecordEntity] = []
    
    var body: some View {
        List {
            ForEach(records) { record in
                Text(String(record.time))
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
