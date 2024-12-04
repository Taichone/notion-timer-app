//
//  ConditionalHiddenModifier.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/21.
//

import SwiftUI

struct ConditionalHiddenModifier: ViewModifier {
    var hidden: Bool

    func body(content: Content) -> some View {
        if self.hidden {
            content
                .hidden()
        } else {
            content
        }
    }
}

extension View {
    public func hidden(_ hidden: Bool) -> some View {
        self.modifier(ConditionalHiddenModifier(hidden: hidden))
    }
}
