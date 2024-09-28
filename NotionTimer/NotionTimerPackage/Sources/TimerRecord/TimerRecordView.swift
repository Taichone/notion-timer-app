//
//  TimerRecordView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import SwiftUI

public struct TimerRecordView: View {
    public let resultFocusTimeSec: Int
    
    public var body: some View {
        Text(String(resultFocusTimeSec))
    }
}

#Preview {
    TimerRecordView(resultFocusTimeSec: 3661)
}
