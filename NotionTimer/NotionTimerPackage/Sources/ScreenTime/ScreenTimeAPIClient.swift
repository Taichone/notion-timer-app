//
//  FamilyControls.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/19.
//

import FamilyControls
import ManagedSettings

public final class ScreenTimeAPIClient {
    private let store = ManagedSettingsStore()
    
    @MainActor public static let shared = ScreenTimeAPIClient()
    private init() {}
    
}

extension ScreenTimeAPIClient: ScreenTimeAPIProtocol {
    public func authorize() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        } catch {
            print("Failed to authorize: \(error)") // TODO: Handle error
        }
    }
    
    public func startAppRestriction(apps: Set<ApplicationToken>?) {
        store.shield.applications = apps
    }

    public func stopAppRestriction() {
        store.shield.applications = nil
    }
}

public protocol ScreenTimeAPIProtocol {
    func authorize() async
    func startAppRestriction(apps: Set<ApplicationToken>?)
    func stopAppRestriction()
}
