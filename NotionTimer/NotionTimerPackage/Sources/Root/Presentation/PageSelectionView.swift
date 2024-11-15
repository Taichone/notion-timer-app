//
//  PageSelectionView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import SwiftUI
import Notion

struct PageSelectionView: View {
    @Environment(NotionService.self) private var authService: NotionService
    
    var body: some View {
        VStack {
            Text("PageSelectionView")
        }
    }
}

#Preview {
    PageSelectionView()
}
