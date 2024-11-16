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
    
    // TODO: DB 検索機能
    
    var body: some View {
        ZStack {
            CommonLoadingView()
                .hidden(!isLoading)
            
            List {
                Button {
                    // TODO: データベースを新規作成
                    print("データベースを新規作成")
                } label: {
                    Text(String(moduleLocalized: "create-new-db"))
                }
                
                Section(String(moduleLocalized: "existing-db")) {
                    ForEach(databases) { database in
                        Button {
                            // TODO: データベースを選択
                            print(database.title)
                        } label: {
                            Text(database.title)
                        }
                    }
                }
            }
        }
        .navigationTitle(String(moduleLocalized: "database-selection-view"))
        .task {
            await fetchDatabases()
        }
    }
    
    private func fetchDatabases() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            databases = try await notionService.getDatabaseList()
        } catch {
            // TODO: ハンドリング
            debugPrint("データベース一覧の取得に失敗")
        }
    }
}

#Preview {
    DatabaseSelectionView()
}


/*
 // 1. データベースの構造を取得
 let database = fetchDatabase(databaseId)
 let existingProperties = database["properties"]

 // 2. 追加したいプロパティが存在するか確認
 if !existingProperties.contains("NewProperty") {
     // 3. 存在しなければ新しいプロパティを追加
     addNewPropertyToDatabase(databaseId, propertyName: "NewProperty", propertyType: "rich_text")
 }

 */
