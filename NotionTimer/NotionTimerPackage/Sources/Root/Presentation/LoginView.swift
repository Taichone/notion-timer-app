//
//  AuthView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import SwiftUI
import Common

struct LoginView: View {
    private static let notionLoginPageURL = URL(string: "https://api.notion.com/v1/oauth/authorize?client_id=131d872b-594c-8062-9bf9-0037ad7ce49b&response_type=code&owner=user&redirect_uri=https%3A%2F%2Ftaichone.github.io%2Fnotion-timer-web%2F")!
    
    var body: some View {
        // TODO: ログインの流れを説明する
        VStack {
            Button {
                UIApplication.shared.open(Self.notionLoginPageURL)
            } label: {
                Text(String(moduleLocalized: "authorize-notion"))
                    .padding()
                    .background {
                        GlassmorphismRoundedRectangle()
                    }
            }
            .tint(Color(.label))
        }
    }
}

#Preview {
    ZStack {
        Color.black
        LoginView()
    }
}
