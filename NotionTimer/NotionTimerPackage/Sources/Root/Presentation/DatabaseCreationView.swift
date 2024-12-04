//
//  DatabaseCreationView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/16.
//

import SwiftUI
import NotionData
import Common

struct DatabaseCreationView: View {
    @Environment(NotionService.self) private var notionService
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var title: String = ""
    @State private var pages: [PageEntity] = []
    @State private var selectedParentPage: PageEntity?
    
    var body: some View {
        ZStack {
            Form {
                Section (
                    content: {
                        Picker("", selection: $selectedParentPage) {
                            ForEach(pages) { page in
                                Text("\(page.title)").tag(page)
                            }
                            Text(String(moduleLocalized: "parent-page-unselected"))
                                .tag(PageEntity?.none)
                                .foregroundStyle(Color(.tertiaryLabel))
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
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
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
                    guard let selectedPageID = selectedParentPage?.id else {
                        fatalError("ERROR: selectedParentPage が nil でも OK ボタンが押せている")
                    }
                    Task { await createDatabase(parentPageID: selectedPageID, title: title) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(title.isEmpty || isLoading || selectedParentPage == nil)
            }
        }
    }
    
    private func fetchPages() async {
        isLoading = true
        do {
            let selectedPageID = selectedParentPage?.id
            
            pages = try await notionService.getPageList()
            
            if let selectedPageID = selectedPageID {
                selectedParentPage = pages.first { $0.id == selectedPageID }
            } else {
                selectedParentPage = nil
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
