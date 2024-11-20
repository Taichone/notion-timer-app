//
//  DatabaseCreationView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/16.
//

import SwiftUI
import Notion
import Common

struct DatabaseCreationView: View {
    @Environment(NotionService.self) private var notionService
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var title: String = ""
    @State private var pages: [PageEntity] = []
    @State private var selectedPage: PageEntity?
    
    var body: some View {
        ZStack {
            Form {
                Section (
                    content: {
                        Picker("", selection: $selectedPage) {
                            ForEach(pages) { page in
                                Text("\(page.title)").tag(page)
                            }
                            Text(String(moduleLocalized: "page-unselected")).tag(PageEntity?.none)
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    },
                    header: {
                        Text(String(moduleLocalized: "parent-page"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "parent-page-description"))
                    }
                )
                
                Section (
                    content: {
                        TextField(String(moduleLocalized: "new-database-title-text-field-spaceholder"), text: $title)
                    },
                    header: {
                        Text(String(moduleLocalized: "new-database-title"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "new-database-title-description"))
                    }
                )
            }
            
            CommonLoadingView()
                .hidden(!isLoading)
        }
        .navigationTitle(String(moduleLocalized: "database-creation-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchPages()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await fetchPages() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard let selectedPageID = selectedPage?.id else {
                        fatalError("ERROR: selectedPage が nil でも OK ボタンが押せている")
                    }
                    Task { await createDatabase(parentPageID: selectedPageID, title: title) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(title.isEmpty || isLoading || selectedPage == nil)
            }
        }
    }
    
    private func fetchPages() async {
        isLoading = true
        do {
            let selectedPageID = selectedPage?.id
            
            pages = try await notionService.getPageList()
            
            if let selectedPageID = selectedPageID {
                selectedPage = pages.first { $0.id == selectedPageID }
            } else {
                selectedPage = nil
            }
        } catch {
            debugPrint("ERROR: ページ一覧の取得に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
    
    private func createDatabase(parentPageID: String, title: String) async {
        isLoading = true
        do {
            try await notionService.createDatabase(parentPageID: parentPageID, title: title)
            dismiss()
        } catch {
            debugPrint("ERROR: データベースの作成に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        DatabaseCreationView()
            .environment(NotionService())
    }
}
