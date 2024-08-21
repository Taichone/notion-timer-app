//
//  FamilyControls.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/19.
//

import FamilyControls
import ManagedSettings

final class ScreenTimeAPI {
    private let store = ManagedSettingsStore()
    
    /// Singleton
    static let shared = ScreenTimeAPI()
    private init() {}
    
}

extension ScreenTimeAPI: ScreenTimeAPIProtocol {
    func authorize() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            print("Failed to authorize: \(error)") // TODO: Handle error
        }
    }
    
    func startAppRestriction(apps: Set<ApplicationToken>?) {
        store.shield.applications = apps
    }

    func stopAppRestriction() {
        store.shield.applications = nil
    }
}
