//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import SwiftData
import Home
import Record

public struct RootView: View {
    public init() {}
    
    public var body: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
