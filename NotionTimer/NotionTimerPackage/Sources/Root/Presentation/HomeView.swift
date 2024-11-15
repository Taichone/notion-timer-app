//
//  HomeView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//

import SwiftUI
import Timer
import Notion

struct HomeView: View {
    init() {}
    
    var body: some View {
        VStack {
            // TODO: Notion DB から記録を取得して表示
//            RecordsPreviewCard(records: records)
            
            Spacer()
            
            NavigationLink {
                TimerSettingView()
            } label: {
                Text("Timer")
            }
        }
        .padding()
        .task {
            // TODO: デバッグの残骸なので消す
            let repository = NotionRepository()
            if let pages = try? await repository.getPageList() {
                pages.forEach {
                    print($0.title)
                }
            } else {
                print("PageList 取得できず")
            }
        }
    }
}

/*
struct RecordsPreviewCard: View {
    var records: [Record]

    var body: some View {
        NavigationStack {
            FlippableCard(
                height: 350,
                frontContent: {
                    // TODO: Swift Charts で taskCategory 毎に time をグラフ表示
                    VStack {
                        Text(records.first?.taskCategory.name ?? "ないよ")
                        Text(String(records.first?.time ?? 0))
                    }
                },
                backContent: {
                    Text("Back")
                }
            )
        }
    }
}
*/
