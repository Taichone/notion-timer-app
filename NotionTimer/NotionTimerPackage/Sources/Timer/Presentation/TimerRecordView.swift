//
//  TimerRecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI
import Notion
import Common

public struct TimerRecordView: View {
    @Environment(NotionService.self) private var notionService: NotionService
    @State private var description: String = ""
    @State private var tags: [TagEntity] = []
    @State private var selectedTags: Set<TagEntity> = []
    @State private var isLoading: Bool = true
    private let resultFocusTimeSec: Int
    
    public init(resultFocusTimeSec: Int) {
        self.resultFocusTimeSec = resultFocusTimeSec
    }
    
    public var body: some View {
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
                        }
                        Button {
                            print("TODO: 新規タグ作成")
                        } label: {
                            Text(String(moduleLocalized: "add-new-tag"))
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
                        // TODO: HomeView に戻る（router で書き直すか）
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(isLoading)
            }
        }
    }
    
    /*
    private func addNewTag(name: String, color: TagEntity.Color) {
        // name, color と、success で返ってくる？タグの ID で、tagItems に追加（）
    }
     */
    
    // TODO: tag を複数選択可能に
    private func record(tags: [TagEntity], description: String) async {
        isLoading = true
        do {
            try await notionService.record(
                time: resultFocusTimeSec,
                tags: tags,
                description: description
            )
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

#Preview {
    TimerRecordView(resultFocusTimeSec: 3661)
}

extension TagEntity.Color {
    var color: SwiftUI.Color {
        switch self {
        case .blue: Color("NotionBlue", bundle: .module)
        case .brown: Color("NotionBrown", bundle: .module)
        case .default: Color("NotionDefault", bundle: .module)
        case .gray: Color("NotionGray", bundle: .module)
        case .green: Color("NotionGreen", bundle: .module)
        case .orange: Color("NotionOrange", bundle: .module)
        case .pink: Color("NotionPink", bundle: .module)
        case .purple: Color("NotionPurple", bundle: .module)
        case .red: Color("NotionRed", bundle: .module)
        case .yellow: Color("NotionYellow", bundle: .module)
        }
    }
}
