//
//  HomeView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//

import SwiftUI
import Timer
import Notion
import Common

struct HomeView: View {
    @Environment(NotionService.self) private var notionService
    
    var body: some View {
        VStack {
            // TODO: Notion DB から記録を取得して表示
            RecordsPreviewCard(service: notionService)
            
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
                
                NavigationLink {
                    TimerSettingView()
                } label: {
                    Text("Timer")
                }
            }
        }
        .padding()
    }
}


struct RecordsPreviewCard: View {
    let service: NotionService
    
    var body: some View {
        NavigationStack {
            FlippableCard(
                height: 350,
                frontContent: {
                    // TODO: Swift Charts で taskCategory 毎に time をグラフ表示
                    EmptyView()
                },
                backContent: {
                    EmptyView()
                }
            )
        }
    }
}
