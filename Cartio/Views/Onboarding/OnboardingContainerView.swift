//
//  OnboardingContainerView.swift
//  Cartio
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: OnboardingViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                onboardingContent(vm)
            } else {
                LoadingView()
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DependencyContainer.shared.makeOnboardingViewModel(modelContext: modelContext)
            }
        }
    }

    private func onboardingContent(_ vm: OnboardingViewModel) -> some View {
        @Bindable var bindableVM = vm
        return VStack(spacing: 0) {
            pageIndicator(currentPage: vm.currentPage)
                .padding(.top, CartioSpacing.lg)
                .padding(.bottom, CartioSpacing.sm)

            TabView(selection: $bindableVM.currentPage) {
                WelcomeView(viewModel: vm)
                    .tag(0)

                DetailsView(viewModel: vm)
                    .tag(1)

                PremiumPitchView(viewModel: vm)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(CartioColors.background)
    }

    private func pageIndicator(currentPage: Int) -> some View {
        HStack(spacing: CartioSpacing.sm) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? CartioColors.primary : CartioColors.textSecondary.opacity(0.3))
                    .frame(width: index == currentPage ? CartioSpacing.lg : CartioSpacing.sm, height: CartioSpacing.sm)
                    .reduceMotionAnimation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of 3")
    }
}
