//
//  CartioApp.swift
//  Cartio
//

import SwiftUI
import SwiftData

@main
struct CartioApp: App {
    @State private var router = AppRouter()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        DependencyContainer.shared.subscriptionService.startTransactionListener()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .onOpenURL { url in
                    router.handleDeepLink(url)
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        router.checkPendingIntentNavigation()
                    }
                }
        }
        .modelContainer(for: CartioSchemaV2.models)
    }
}

// MARK: - Root View

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        Group {
            switch router.state {
            case .loading:
                LoadingView(message: "Loading...")
                    .onAppear { router.checkAuthState() }
            case .onboarding:
                OnboardingContainerView()
            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: router.state)
    }
}
