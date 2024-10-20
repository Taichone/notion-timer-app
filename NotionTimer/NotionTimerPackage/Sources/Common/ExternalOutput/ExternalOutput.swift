//
//  ExternalFeedback.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/07.
//

import UIKit.UIImpactFeedbackGenerator

public struct ExternalOutput {
    @MainActor public static func tapticFeedback() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
