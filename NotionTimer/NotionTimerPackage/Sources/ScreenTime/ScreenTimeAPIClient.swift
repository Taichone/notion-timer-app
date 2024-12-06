//
//  FamilyControls.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/19.
//

import FamilyControls
import ManagedSettings

extension FamilyActivitySelection: @retroactive @unchecked Sendable {}
extension ManagedSettingsStore: @retroactive @unchecked Sendable {}

protocol DependencyClient: Sendable {
    static var liveValue: Self { get }
    static var testValue: Self { get }
}

public struct ScreenTimeClient: DependencyClient {
    public static let appSelection = FamilyActivitySelection()
    
    public var authorize: @Sendable () async throws -> Void
    public var startAppRestriction: @Sendable (Set<ApplicationToken>?) -> Void
    public var stopAppRestriction: @Sendable () -> Void
    
    public static let liveValue = Self(
        authorize: { try await authorize() },
        startAppRestriction: { startAppRestriction(apps: $0) },
        stopAppRestriction: { stopAppRestriction() }
    )
    
    public static let testValue = Self(
        authorize: {},
        startAppRestriction: { _ in },
        stopAppRestriction: {}
    )
}

extension ScreenTimeClient {
    private static let store = ManagedSettingsStore()
    
    static func authorize() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
    
    static func startAppRestriction(apps: Set<ApplicationToken>?) {
        store.shield.applications = apps
    }

    static func stopAppRestriction() {
        store.shield.applications = nil
    }
}
