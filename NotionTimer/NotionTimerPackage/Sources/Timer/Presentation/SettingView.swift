//
//  SettingView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/02.
//

import SwiftUI
import NotionData

struct SettingView: View {
    @Environment(NotionService.self) private var notionService
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        List {
            Section (
                content: {
                    Button {
                        notionService.releaseSelectedDatabase()
                        router.items.removeAll()
                    } label: {
                        Text(String(moduleLocalized: "reselect-database"))
                    }
                },
                footer: {
                    Text(String(moduleLocalized: "reselect-database-description"))
                }
            )

            Section (
                content: {
                    Button {
                        notionService.releaseAccessToken()
                        router.items.removeAll()
                    } label: {
                        Text(String(moduleLocalized: "logout"))
                    }
                },
                footer: {
                    Text(String(moduleLocalized: "logout-description"))
                }
            )
        }
        .navigationTitle(String(moduleLocalized: "setting-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
