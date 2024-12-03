//
//  SettingView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/02.
//

import SwiftUI
import Notion

struct SettingView: View {
    @Environment(NotionService.self) private var notionService
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        List {
            Button {
                notionService.releaseSelectedDatabase()
                router.items.removeAll()
            } label: {
                Text(String(moduleLocalized: "reselect-database"))
            }
            Button {
                notionService.releaseAccessToken()
                router.items.removeAll()
            } label: {
                Text(String(moduleLocalized: "logout"))
            }
        }
        .navigationTitle(String(moduleLocalized: "setting-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
