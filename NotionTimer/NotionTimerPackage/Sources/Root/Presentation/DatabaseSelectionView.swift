//
//  DatabaseSelectionView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import SwiftUI
import Notion
import Common

struct DatabaseSelectionView: View {
    @Environment(NotionService.self) private var notionService: NotionService
    @State private var isLoading = true
    @State private var databases: [Database] = []
    
    var body: some View {
        ZStack {
            CommonGradient()
            
            if isLoading {
                CommonLoadingView()
            } else {
                List {
                    ForEach(databases) { database in
                        Text(database.title)
                    }
                }
            }
        }
        .navigationTitle(String(moduleLocalized: "database-selection-view"))
        .task {
            do {
                databases = try await notionService.getDatabaseList()
                isLoading = false
            } catch {
                // TODO: ハンドリング
                debugPrint("データベース一覧の取得に失敗")
            }
        }
    }
}

#Preview {
    DatabaseSelectionView()
}
