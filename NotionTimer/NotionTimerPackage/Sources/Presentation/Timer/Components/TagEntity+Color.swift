//
//  TagEntity+Color.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/03.
//

import SwiftUI
import Notion

extension TagEntity.Color {
    var color: SwiftUI.Color {
        switch self {
        case .blue: Color("NotionBlue", bundle: .module)
        case .brown: Color("NotionBrown", bundle: .module)
        case .default: Color("NotionDefault", bundle: .module)
        case .gray: Color("NotionGray", bundle: .module)
        case .green: Color("NotionGreen", bundle: .module)
        case .orange: Color("NotionOrange", bundle: .module)
        case .pink: Color("NotionPink", bundle: .module)
        case .purple: Color("NotionPurple", bundle: .module)
        case .red: Color("NotionRed", bundle: .module)
        case .yellow: Color("NotionYellow", bundle: .module)
        }
    }
}
