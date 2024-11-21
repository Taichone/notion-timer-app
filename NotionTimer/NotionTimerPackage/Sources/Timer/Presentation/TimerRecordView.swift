//
//  TimerRecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI
import Notion
import Common

struct TagEntity: Identifiable, Hashable {
    let id: String
    let name: String
    let color: Color
    
    enum Color: String {
        case blue
        case brown
        case `default`
        case gray
        case green
        case orange
        case pink
        case purple
        case red
        case yellow
        
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
}

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
                                    .background {
                                        RoundedRectangle(cornerRadius: 5)
                                            .foregroundStyle(tag.color.color)
                                    }
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
            print("TODO: fetchDatabaseTags()")
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("TODO: fetchDatabaseTags()")
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await record(tagID: selectedTag?.id, description: description) }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(isLoading)
            }
        }
    }
    
    private func record(tagID: String?, description: String) async {
        do {
            try await notionService.record(
                time: resultFocusTimeSec,
                tagID: tagID,
                description: description
            )
        } catch {
            debugPrint(error.localizedDescription) // TODO: ハンドリング
        }
    }
}

#Preview {
    TimerRecordView(resultFocusTimeSec: 3661)
}
