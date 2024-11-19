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
    @State private var isLoading = true
    @State private var title: String = ""
    @State private var pages: [PageEntity] = [.placeholder]
    @State private var selectedPage: PageEntity = .placeholder
    
    var body: some View {
        ZStack {
            Form {
                Section (
                    content: {
                        Picker("", selection: $selectedPage) {
                            ForEach(pages) { page in
                                Text("\(page.title)").tag(page)
                            }
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    },
                    header: {
                        Text(String(moduleLocalized: "select-parent-page"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "select-parent-page-description"))
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
        .navigationTitle(String("database-creation-view"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard selectedPage == .placeholder else { return }
            await fetchPages()
            guard let firstPage = pages.first else {
                debugPrint("TODO: ページが無いときのハンドリング")
                return
            }
            selectedPage = firstPage
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
                    Task { await createDatabase(parentPageID: selectedPage.id, title: title) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(title.isEmpty || isLoading || selectedPage.id == PageEntity.placeholderID)
            }
        }
    }
    
    private func fetchPages() async {
        isLoading = true
        do {
            self.pages = try await notionService.getPageList()
        } catch {
            debugPrint("ページ一覧の取得に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
    
    private func createDatabase(parentPageID: String, title: String) async {
        isLoading = true
        do {
            try await notionService.createDatabase(parentPageID: parentPageID, title: title)
        } catch {
            debugPrint("データベースの作成に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
}

#Preview {
    DatabaseCreationView()
        .environment(NotionService())
}

extension PageEntity {
    public static let placeholderID: String = "Placeholder"
    public static let placeholder: PageEntity = .init(
        id: placeholderID,
        title: String(moduleLocalized: "placeholder-page-title")
    )
}
