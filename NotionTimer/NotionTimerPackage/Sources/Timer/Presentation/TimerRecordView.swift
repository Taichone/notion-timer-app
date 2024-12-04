//
//  TimerRecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI
import Notion
import Common

struct TimerRecordView: View {
    @Environment(NotionService.self) private var notionService: NotionService
    @EnvironmentObject private var router: NavigationRouter
    @State private var description: String = ""
    @State private var tags: [TagEntity] = []
    @State private var selectedTags: Set<TagEntity> = []
    @State private var isLoading: Bool = true
    private let resultFocusTimeSec: Int
    
    init(dependency: Dependency) {
        self.resultFocusTimeSec = dependency.resultFocusTimeSec
    }
    
    var body: some View {
        ZStack {
            List(selection: $selectedTags) {
                Group {
                    Section (
                        content: {
                            TextEditor(text: $description)
                                .frame(height: 100)
                        },
                        header: {
                            Text(String(moduleLocalized: "record-description"))
                        },
                        footer: {
                            Text(String(moduleLocalized: "record-description-description"))
                        }
                    )
                }
                
                Section (
                    content: {
                        ForEach(tags) { tag in
                            Text(tag.name)
                                .tag(tag)
                                .listRowBackground(tag.color.color)
                                .foregroundStyle(.black)
                        }
                    },
                    header: {
                        Text(String(moduleLocalized: "tag"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "tag-description"))
                    }
                )
            }
            .environment(\.editMode, .constant(.active))
            
            CommonLoadingView()
                .hidden(!isLoading)
        }
        .navigationTitle(String(moduleLocalized: "timer-record-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
            await fetchDatabaseTags()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await fetchDatabaseTags() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await record(tags: Array(selectedTags), description: description)
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(isLoading)
            }
        }
    }
    
    private func record(tags: [TagEntity], description: String) async {
        isLoading = true
        do {
            try await notionService.record(
                time: resultFocusTimeSec,
                tags: tags,
                description: description
            )
            router.items.removeAll() // HomeView に戻る
        } catch {
            debugPrint(error.localizedDescription) // TODO: ハンドリング
        }
        isLoading = false
    }
    
    private func fetchDatabaseTags() async {
        isLoading = true
        do {
            tags = try await notionService.getDatabaseTags()
        } catch {
            debugPrint(error.localizedDescription) // TODO: ハンドリング
        }
        isLoading = false
    }
}

extension TimerRecordView {
    struct Dependency: Hashable {
        let resultFocusTimeSec: Int
    }
}

#Preview {
    TimerRecordView(dependency: .init(resultFocusTimeSec: 3661))
}
