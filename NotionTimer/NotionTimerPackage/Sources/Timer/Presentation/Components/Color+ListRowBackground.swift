//
//  Color+ListRowBackground.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/04.
//

import SwiftUI

extension Color {
    static var listRowBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.secondarySystemBackground
            } else {
                return UIColor.systemBackground
            }
        })
    }
}
