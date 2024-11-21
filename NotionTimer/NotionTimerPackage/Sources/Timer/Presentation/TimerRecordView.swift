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
    @State private var selectedTag: TagEntity?
    @State private var isLoading: Bool = true
    public let resultFocusTimeSec: Int
    
    public init(resultFocusTimeSec: Int) {
        self.resultFocusTimeSec = resultFocusTimeSec
    }
    
    public var body: some View {
        ZStack {
            Form {
                Section (
                    content: {
                        Picker("", selection: $selectedTag) {
                            ForEach(tags) { tag in
                                Text("\(tag.name)").tag(tag)
                                    .padding(5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundStyle(tag.color.color)
                                    }
                                    .tag(tag)
                            }
                            Text(String(moduleLocalized: "tag-unselected"))
                                .tag(TagEntity?.none)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    },
                    header: {
                        Text(String(moduleLocalized: "tag"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "tag-description"))
                    }
                )
                
                Section (
                    content: {
                        TextField(String(moduleLocalized: "record-description-text-field-spaceholder"), text: $description)
                    },
                    header: {
                        Text(String(moduleLocalized: "record-description"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "record-description-description"))
                    }
                )
            }
            
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
                        await record(tagID: selectedTag?.id, description: description)
                        // TODO: HomeView に戻る（router で書き直すか）
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(isLoading)
            }
        }
    }
    
    // TODO: tag を複数選択可能に
    private func record(tagID: String?, description: String) async {
        isLoading = true
        do {
            try await notionService.record(
                time: resultFocusTimeSec,
                tagID: tagID,
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
        case .blue: .blue
        case .brown: .brown
        case .default: .gray
        case .gray: .gray
        case .green: .green
        case .orange: .orange
        case .pink: .pink
        case .purple: .purple
        case .red: .red
        case .yellow: .yellow
        }
    }
}
