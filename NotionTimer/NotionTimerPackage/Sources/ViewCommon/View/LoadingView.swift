//
//  LoadingView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/09/11.
//

import SwiftUI

struct LoadingView<Content: View>: View {
    let label: String
    let textColor: Color
    let backgroundContent: Content

    init(label: String, textColor: Color, @ViewBuilder content: () -> Content) {
        self.label = label
        self.textColor = textColor
        self.backgroundContent = content()
    }

    var body: some View {
        VStack {
            ProgressView()
                .padding()
            Text(label)
                .foregroundStyle(textColor)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .background {
            backgroundContent
        }
    }
}

#Preview {
    LoadingView(label: "読込中", textColor: .gray) {
        GlassmorphismRoundedRectangle()
    }
}
