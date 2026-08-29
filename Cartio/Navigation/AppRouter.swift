//
//  AppRouter.swift
//  Cartio
//

import SwiftUI

@Observable
final class AppRouter {

    enum AppState: Equatable {
        case loading
        case onboarding
        case authenticated
    }

    var state: AppState = .loading
    var selectedTab: TabDestination = .cards
    var presentingCardEditor = false
    var showQRFullscreen = false

    // MARK: - Lifecycle

    func checkAuthState() {
        // TODO: Check FirebaseAuth.auth().currentUser
        // For now, check if onboarding was completed
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            state = .authenticated
        } else {
            state = .onboarding
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        state = .authenticated
    }

    func signOut() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        state = .onboarding
    }

    func checkPendingIntentNavigation() {
        guard state == .authenticated else { return }
        guard let link = UserDefaults.standard.string(forKey: "pendingDeepLink") else { return }
        UserDefaults.standard.removeObject(forKey: "pendingDeepLink")
        guard let url = URL(string: link) else { return }
        handleDeepLink(url)
    }

    // MARK: - Deep Links

    func handleDeepLink(_ url: URL) {
        // Handle custom scheme (cartio://share from widget)
        if url.scheme == "cartio" {
            guard state == .authenticated else { return }
            switch url.host() {
            case "share":
                selectedTab = .share
            case "qr-fullscreen":
                selectedTab = .share
                showQRFullscreen = true
            default:
                break
            }
            return
        }

        guard let host = url.host() else { return }

        let path = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "cartio.me":
            if path.first == "app", path.count >= 3 {
                // cartio.me/app/card/{id} or cartio.me/app/contact/{id}
                handleAppDeepLink(type: path[1], id: path[2])
            }
        default:
            break
        }
    }

    private func handleAppDeepLink(type: String, id: String) {
        guard state == .authenticated else { return }

        switch type {
        case "card":
            selectedTab = .cards
            // TODO: Navigate to specific card
        case "contact":
            selectedTab = .contacts
            // TODO: Navigate to specific contact
        default:
            break
        }
    }
}

// MARK: - Tab Destination

enum TabDestination: Int, Hashable {
    case cards = 0
    case share = 1
    case contacts = 2
    case profile = 3
}
