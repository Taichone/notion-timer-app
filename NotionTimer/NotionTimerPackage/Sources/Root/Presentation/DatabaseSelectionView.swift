//
//  DatabaseSelectionView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import SwiftUI
import Notion
import Common

enum SelectedDatabaseType {
    case newDatabase(name: String)
    case existing(database: Database)
}

struct DatabaseSelectionView: View {
    @Environment(NotionService.self) private var notionService: NotionService
    @State private var isLoading = true
    @State private var databases: [Database] = []
    @State private var selectedDatabase: SelectedDatabaseType?
    @State private var newDatabaseName: String = String(moduleLocalized: "new-database")
    @State private var isNewDatabaseNameAlertPresented: Bool = false
    
    // TODO: DB 検索機能
    
    var body: some View {
        ZStack {
            Form {
                Section(String(moduleLocalized: "create-new-db")) {
                    Button {
                        isNewDatabaseNameAlertPresented = true
                    } label: {
                        HStack {
                            Text(newDatabaseName)
                            Spacer()
                            Image(systemName: "checkmark")
                                .hidden(hiddenCheckmarkForNewDatabase())
                        }
                    }
                }
                
                Section(String(moduleLocalized: "select-existing-db")) {
                    ForEach(databases) { database in
                        Button {
                            selectedDatabase = .existing(database: database)
                        } label: {
                            HStack {
                                Text(database.title)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .hidden(hiddenCheckmarkForExisting(database))
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
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task { await fetchDatabases() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("TODO: データベース接続処理")
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(selectedDatabase == nil)
            }
        }
        // 新規データベース名入力用アラート
        .alert(
            String(moduleLocalized: "new-database-name"),
            isPresented: $isNewDatabaseNameAlertPresented
        ) {
            TextField(
                String(moduleLocalized: "new-database"),
                text: $newDatabaseName
            )
            
            Button {
                selectedDatabase = .newDatabase(name: newDatabaseName)
            } label: {
                Text(String(moduleLocalized: "ok"))
            }
            .disabled(newDatabaseName.isEmpty)
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
    
    private func hiddenCheckmarkForNewDatabase() -> Bool {
        guard let selectedDatabase = selectedDatabase else { return true }
        switch selectedDatabase {
        case .newDatabase:
            return false
        case .existing:
            return true
        }
    }
    
    private func hiddenCheckmarkForExisting(_ database: Database) -> Bool {
        guard let selectedDatabase = selectedDatabase else { return true }
        switch selectedDatabase {
        case .newDatabase:
            return true
        case .existing(let existingDatabase):
            return existingDatabase.id != database.id
        }
    }
}

#Preview {
    DatabaseSelectionView()
}
