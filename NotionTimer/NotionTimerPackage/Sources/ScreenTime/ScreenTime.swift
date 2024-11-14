//
//  ScreenTime.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/09/29.
//

import FamilyControls

// FIXME: なぜ ScreenTimeAPI と分けてる？再検討
public struct ScreenTime {
    public static func appSelection() -> FamilyActivitySelection {
        return FamilyActivitySelection()
    }
}
