//
//  PageSelectionView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import SwiftUI
import Notion

struct PageSelectionView: View {
    @Environment(NotionAuthService.self) private var authService: NotionAuthService
    
    var body: some View {
        VStack {
            Text("PageSelectionView")
        }
    }
}

#Preview {
    PageSelectionView()
}
