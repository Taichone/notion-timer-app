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
    @State private var pages: [Page] = []
    @State private var selectedPage: Page?
    
    var body: some View {
        ZStack {
            Form {
                TextField(String(moduleLocalized: "new-database-title"), text: $title)
                
                Section(String(moduleLocalized: "select-parent-page")) {
                    ForEach(pages) { page in
                        Button {
                            selectedPage = page
                        } label: {
                            HStack {
                                Text(page.title)
                                Spacer()
                                Image(systemName: "checkmark")
                                    .hidden(
                                        selectedPage?.id != page.id
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
                    guard let selectedPage = selectedPage else {
                        fatalError("Error: createDatabase - ページ未選択時に呼ばれた")
                    }
                    Task { await createDatabase(title: title, parentPageID: selectedPage.id) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(selectedPage == nil || title.isEmpty)
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
    
    private func createDatabase(title: String, parentPageID: String) async {
        print("TODO: createDatabase - title: \(title), parentPageID: \(parentPageID)")
    }
}

#Preview {
    DatabaseCreationView()
        .environment(NotionService())
}
