//
//  HomeView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//

import SwiftUI
import Notion
import Common

final class NavigationRouter: ObservableObject {
    @MainActor @Published var items: [Item] = []
    
    init() {}

    enum Item: Hashable {
        case timerSetting
        case timer(dependency: TimerView.Dependency)
        case timerRecord(dependency: TimerRecordView.Dependency)
    }
}

public struct HomeView: View {
    @Environment(NotionService.self) private var notionService
    @StateObject private var router: NavigationRouter = .init()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.items) {
            VStack {
                // TODO: Notion DB から記録を取得して表示
                Spacer()
                
                VStack(spacing: 30) {
                    Button {
                        notionService.releaseSelectedDatabase()
                    } label: {
                        Text("データベースの再選択")
                    }
                    
                    Button {
                        notionService.releaseAccessToken()
                    } label: {
                        Text("ログアウト")
                    }
                    
                    Button {
                        router.items.append(.timerSetting)
                    } label: {
                        Text("Timer")
                    }
                }
            }
            .padding()
            .navigationDestination(for: NavigationRouter.Item.self) { item in
                switch item {
                case .timerSetting:
                    TimerSettingView()
                        .environmentObject(router)
                case .timer(let dependency):
                    TimerView(dependency: dependency)
                        .environmentObject(router)
                case .timerRecord(let dependency):
                    TimerRecordView(dependency: dependency)
                        .environmentObject(router)
                }
            }
        }
    }
}
