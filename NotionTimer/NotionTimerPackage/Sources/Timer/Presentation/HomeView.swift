//
//  HomeView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//

import SwiftUI
import NotionData
import Common

final class NavigationRouter: ObservableObject {
    @MainActor @Published var items: [Item] = []
    
    init() {}

    enum Item: Hashable {
        case setting
        case timerSetting
        case timer(dependency: TimerView.Dependency)
        case timerRecord(dependency: TimerRecordView.Dependency)
    }
}

public struct HomeView: View {
    @StateObject private var router: NavigationRouter = .init()
    
    public init() {}
    
    public var body: some View {
        NavigationStack(path: $router.items) {
            List {
                Section(String(moduleLocalized: "record-display-header")) {
                    RecordDisplayView()
                }
                
                Section(String(moduleLocalized: "timer-button-header")) {
                    Button {
                        router.items.append(.timerSetting)
                    } label: {
                        Text(String(moduleLocalized: "timer-navigation-phrase"))
                            .bold()
                    }
                }
            }
            .navigationDestination(for: NavigationRouter.Item.self) { item in
                switch item {
                case .setting:
                    SettingView()
                        .environmentObject(router)
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
            .navigationTitle(String(moduleLocalized: "home-view-navigation-title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        router.items.append(.setting)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
    }
}
