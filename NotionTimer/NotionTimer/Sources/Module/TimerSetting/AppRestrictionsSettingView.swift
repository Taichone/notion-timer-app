//
//  AppRestrictionsSettingView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/19.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct AppRestrictionsSettingView: View {
    @State private var isPresented = false
    @State private var selectedApps = FamilyActivitySelection()
    @State private var isRestrictionActive = false
    
    private let api: ScreenTimeAPIProtocol
    
    init(api: ScreenTimeAPIProtocol) {
        self.api = api
    }
    
    var body: some View {
        VStack {
            Button("アプリを選択") {
                Task {
                    await self.api.authorize()
                    self.isPresented = true
                }
            }
            .padding()
            .familyActivityPicker(isPresented: self.$isPresented, selection: self.$selectedApps)
            
            Text("\(self.selectedApps.applications.count)")
            Text("\(self.selectedApps.applicationTokens.count)")
            Text("\(self.selectedApps.categories.count)")
            Text("\(self.selectedApps.categoryTokens.count)")

            Button("開始") {
                self.api.startAppRestriction(apps: self.selectedApps.applicationTokens)
                self.isRestrictionActive = true
            }
            .padding()
            .disabled(self.selectedApps.applicationTokens.isEmpty || self.isRestrictionActive)

            Button("終了") {
                self.api.stopAppRestriction()
                self.isRestrictionActive = false
            }
            .padding()
            .disabled(!self.isRestrictionActive)
        }
    }
}

protocol ScreenTimeAPIProtocol {
    func authorize() async
    func startAppRestriction(apps: Set<ApplicationToken>?)
    func stopAppRestriction()
}
