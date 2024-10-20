//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import SwiftData
import TimerSetting
import Record
import Common

public struct RootView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("darkBlue", bundle: CommonColor.bundle), .black]),
                    startPoint: .topLeading, endPoint: .bottom
                ).ignoresSafeArea()
                
                VStack {
                    RecordsPreviewCard()
                    
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

#Preview {
    RootView()
}

struct RecordsPreviewCard: View {
    @Environment(\.modelContext) private var context
    @Query private var records: [TaskCategoryRecord]

    var body: some View {
        NavigationStack {
            FlippableCard(
                height: 350,
                frontContent: {
                    // TODO: Swift Charts で category 毎に time をグラフ表示
                    VStack {
                        Text(records.first?.category.name ?? "ないよ")
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
