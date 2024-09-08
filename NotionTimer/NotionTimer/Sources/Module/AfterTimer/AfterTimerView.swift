//
//  AfterTimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct AfterTimerView: View {
    let resultFocusTimeSec: Int

    var body: some View {
        Text(String(resultFocusTimeSec))
    }
}

#Preview {
    AfterTimerView(resultFocusTimeSec: 3661)
}
