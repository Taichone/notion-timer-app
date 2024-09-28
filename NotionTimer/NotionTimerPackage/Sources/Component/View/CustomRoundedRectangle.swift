//
//  CustomRoundedRectangle.swift
//  NotionTimer
//
//  Created by Taichi on 2024/09/11.
//

import SwiftUI

struct CustomRoundedRectangle: View {
    let type: TemplateType

    var body: some View {
        switch type {
        case let .custom(lightColor, color, shadowColor):
            Content(
                lightColor: lightColor,
                color: color,
                shadowColor: shadowColor
            )
        }
    }

    enum TemplateType {
        case custom(lightColor: Color, color: Color, shadowColor: Color)
    }

    struct Content: View {
        let lightColor: Color
        let color: Color
        let shadowColor: Color
        let radius: CGFloat = 15

        var body: some View {
            RoundedRectangle(cornerRadius: radius)
                .fill(
                    .shadow(.inner(color: lightColor, radius: 6, x: 4, y: 4)) // 上部の光沢
                    .shadow(.inner(color: shadowColor, radius: 6, x: -2, y: -2)) // 下部の影
                )
                .foregroundStyle(color)
                .shadow(radius: 10, x: 5, y: 5)
        }
    }
}

#Preview {
    VStack {
        CustomRoundedRectangle(type: .custom(
            lightColor: .white,
            color: Color(.systemGray6),
            shadowColor: Color(.systemGray4))
        )
        .frame(height: 100)
        .padding(.vertical)
        
        CustomRoundedRectangle(type: .custom(
            lightColor: .turquoiseLight,
            color: .turquoise,
            shadowColor: .turquoiseShadow)
        )
        .frame(height: 100)
        .padding(.vertical)
    }
    .padding()
}
