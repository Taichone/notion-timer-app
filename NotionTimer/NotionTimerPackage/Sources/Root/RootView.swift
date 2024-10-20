//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import SwiftData
import TimerSetting
import Records
import ViewCommon

public struct RootView: View {
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.mint, .black]),
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ).ignoresSafeArea()
                VStack {
                    FlippableCard(
                        height: 350,
                        frontContent: {
                            Text("Front")
                        },
                        backContent: {
                            Text("Back")
                        }
                    )
                    
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
    }
}

#Preview {
    RootView()
}
