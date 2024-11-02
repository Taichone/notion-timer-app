//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import Home
import Record
import Common

// TODO: Notion Auth の実装
/*
 NotionAuthService を定義して
 ContentView はその authStatus で(HomeView・NotionAuthView）を分岐
 .onOpenURL をつける View は要検討
 遷移は悩みどころ（EnvironmentObject を用いた Coodinator パターンについて調べて検討する）
*/

public struct RootView: View {
    public init() {}
    
    public var body: some View {
        // Auth を実装するまでの仮実装
        VStack {
            HomeView()
            Link("Authorize Notion", destination: URL(string: "https://api.notion.com/v1/oauth/authorize?client_id=131d872b-594c-8062-9bf9-0037ad7ce49b&response_type=code&owner=user&redirect_uri=https%3A%2F%2Ftaichone.github.io%2Fnotion-timer-web%2F")!)
        }
        .preferredColorScheme(.dark)
        .onOpenURL(perform: { url in
            if let deeplink = url.getDeeplink() {
                switch deeplink {
                case .notionTemporaryToken(let token):
                    print(token)
                }
            }
        })
    }
}

#Preview {
    RootView()
}
