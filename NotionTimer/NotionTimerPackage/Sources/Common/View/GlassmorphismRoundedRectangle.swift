//
//  GlassmorphismRoundedRectangle.swift
//  NotionTimer
//
//  Created by Taichi on 2024/09/11.
//

import SwiftUI

public struct GlassmorphismRoundedRectangle: View {
    let radius = CGFloat(15)
    
    public init() {}

    public var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .foregroundStyle(.ultraThinMaterial) // ぼかし効果
            .shadow(color: .init(white: 0.4, opacity: 0.4), radius: 7, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(Color.init(white: 1, opacity: 0.5), lineWidth: 1) // ガラスの縁を表現
            )
    }
}

#Preview {
    GlassmorphismRoundedRectanglePreviewWrapper()
}

fileprivate struct GlassmorphismRoundedRectanglePreviewWrapper: View {
    let frontGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [.green, .mint]),
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    let backGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [.mint, .blue]),
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            Circle()
                .frame(width: 200, height: 200)
                .offset(x: 50, y: 50)
                .foregroundStyle(backGradient)
            Circle()
                .frame(width: 200, height: 200)
                .offset(x: -50, y: -50)
                .foregroundStyle(frontGradient)

            Button {
                print("")
            } label: {
                Text("Glassmorphism")
                    .font(.system(size: 25, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .padding()
                    .background {
                        GlassmorphismRoundedRectangle()
                    }
            }
        }
    }
}
