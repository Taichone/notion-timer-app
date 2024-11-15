//
//  DatabaseSelectionView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import SwiftUI
import Notion
import Common

struct DatabaseSelectionView: View {
    @Environment(NotionService.self) private var notionService: NotionService
    @State private var isLoading = true
    @State private var pages: [Page] = []
    
    var body: some View {
        ZStack {
            CommonGradient()
            
            if isLoading {
                CommonLoadingView()
            } else {
                Text("DatabaseSelectionView")
            }
        }
        .navigationTitle(String(moduleLocalized: "database-selection"))
    }
}

#Preview {
    DatabaseSelectionView()
}
