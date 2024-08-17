//
//  TimerCircle.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct TimerCircle: View {
    private let trimFrom: CGFloat
    private let trimTo: CGFloat
    private let color: Color
    private let strokeWidth: CGFloat
    
    init(
        color: Color,
        trimFrom: CGFloat = 0.0,
        trimTo: CGFloat = 1.0,
        strokeWidth: CGFloat = 50
    ) {
        self.color = color
        self.trimFrom = trimFrom
        self.trimTo = trimTo
        self.strokeWidth = strokeWidth
    }
    
    var body: some View {
        Circle()
            .trim(from: self.trimFrom, to: self.trimTo)
            .stroke(
                self.color,
                style: StrokeStyle(
                    lineWidth: self.strokeWidth,
                    lineCap: .butt,
                    lineJoin: .miter
                )
            )
            .scaledToFit()
            .padding(self.strokeWidth)
    }
}
