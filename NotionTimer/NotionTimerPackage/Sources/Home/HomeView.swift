//
//  HomeView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/21.
//

import SwiftUI
import SwiftData
import TimerSetting
import Record
import Common

public struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query private var records: [Record]
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("darkBlue", bundle: CommonColor.bundle),
                        .black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottom
                ).ignoresSafeArea()
                
                VStack {
                    RecordsPreviewCard(records: records) // TODO: 値渡しも検討
                    
                    Spacer()
                    
                    NavigationLink {
                        TimerSettingView()
                    } label: {
                        Text("Timer")
                    }
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
}

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
