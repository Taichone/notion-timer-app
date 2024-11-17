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
    @State private var selectedDatabase: Database?
    
    var body: some View {
        ZStack {
            List {
                NavigationLink {
                    DatabaseCreationView()
                } label: {
                    Text(String(moduleLocalized: "create-new-db"))
                }
                
                Section(String(moduleLocalized: "existing-db")) {
                    ForEach(databases) { database in
                        Button {
                            selectedDatabase = database
                        } label: {
                            HStack {
                                Text(database.title)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .hidden(
                                        selectedDatabase?.id != database.id
                                    )
                            }
                        }
                        .tint(Color(.label))
                    }
                }
            }
            
            CommonLoadingView()
                .hidden(!isLoading)
        }
        .navigationTitle(String(moduleLocalized: "database-selection-view"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchDatabases()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await fetchDatabases() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard let selectedDatabase = selectedDatabase else {
                        fatalError("Error: setDatabase - データベース未選択時に呼ばれた")
                    }
                    Task { await setExistingDatabase(id: selectedDatabase.id) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(selectedDatabase == nil)
            }
        }
    }
}

extension DatabaseSelectionView {
    private func fetchDatabases() async {
        isLoading = true
        do {
            self.databases = try await notionService.getDatabaseList()
        } catch {
            debugPrint("データベース一覧の取得に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
    
    private func setExistingDatabase(id: String) async {
        isLoading = true
        
        // TODO: 既存データベースの設定
        // notionService.setExistingDatabase(id: database.id)
        print("selectedDatabaseID: \(id)")
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        DatabaseSelectionView()
            .environment(NotionService())
    }
}
