//
//  String+ModuleLocalized.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/14.
//

import Foundation

extension String {
    init(moduleLocalized key: String.LocalizationValue) {
        self.init(localized: key, bundle: .module)
    }
}
