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
    @State private var databases: [DatabaseEntity] = []
    @State private var selectedDatabase: DatabaseEntity = .placeholder
    
    var body: some View {
        ZStack {
            List {
                NavigationLink {
                    DatabaseCreationView()
                } label: {
                    Text(String(moduleLocalized: "create-new-db"))
                }
  
                Section (
                    content: {
                        Picker("", selection: $selectedDatabase) {
                            ForEach(databases) { database in
                                Text("\(database.title)").tag(database)
                            }
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    },
                    header: {
                        Text(String(moduleLocalized: "select-existing-database"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "select-existing-database-description"))
                    }
                )
            }
            
            CommonLoadingView()
                .hidden(!isLoading)
        }
        .navigationTitle(String(moduleLocalized: "database-selection-view"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard selectedDatabase == .placeholder else { return }
            await fetchDatabases()
            guard let firstDatabase = databases.first else {
                debugPrint("TODO: データベースが無いときのハンドリング")
                return
            }
            selectedDatabase = firstDatabase
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
                    Task { await setExistingDatabase(id: selectedDatabase.id) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(isLoading || selectedDatabase == .placeholder)
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


extension DatabaseEntity {
    public static let placeholderID: String = "Placeholder"
    public static let placeholder: DatabaseEntity = .init(
        id: placeholderID,
        title: String(moduleLocalized: "placeholder-database-title")
    )
}
