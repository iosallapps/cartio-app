//
//  MainTabView.swift
//  Cartio
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            Tab("Cards", systemImage: "rectangle.on.rectangle", value: .cards) {
                CardListView(
                    viewModel: DependencyContainer.shared.makeCardsViewModel(modelContext: modelContext)
                )
            }

            Tab("Share", systemImage: "qrcode", value: .share) {
                ShareHubView(
                    viewModel: DependencyContainer.shared.makeShareHubViewModel(modelContext: modelContext)
                )
            }

            Tab("Contacts", systemImage: "person.2", value: .contacts) {
                ContactListView(
                    viewModel: DependencyContainer.shared.makeContactsViewModel(modelContext: modelContext)
                )
            }

            Tab("Profile", systemImage: "person.circle", value: .profile) {
                ProfileView(
                    viewModel: DependencyContainer.shared.makeProfileViewModel(modelContext: modelContext)
                )
            }
        }
        .tint(CartioColors.primary)
    }
}
