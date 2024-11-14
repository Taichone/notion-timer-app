//
//  SwiftUIView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/14.
//

import SwiftUI

public struct CommonGradient: View {
    public init() {}
    
    public var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color("darkBlue", bundle: CommonColor.bundle),
                .black
            ]),
            startPoint: .topLeading,
            endPoint: .bottom
        ).ignoresSafeArea()
    }
}

#Preview {
    CommonGradient()
}
