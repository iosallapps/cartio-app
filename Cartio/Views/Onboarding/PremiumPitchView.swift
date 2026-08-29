//
//  PremiumPitchView.swift
//  Cartio
//

import SwiftUI

struct PremiumPitchView: View {
    @Bindable var viewModel: OnboardingViewModel
    @Environment(AppRouter.self) private var router
    @State private var showError = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: CartioSpacing.sm) {
                    Text("Unlock the full Cartio experience")
                        .font(CartioFonts.title())
                        .foregroundStyle(CartioColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, CartioSpacing.md)

                    FeatureComparisonView()
                        .padding(.bottom, CartioSpacing.lg)

                    PricingCardsView(selectedPlan: $viewModel.selectedPlan)
                }
                .padding(.horizontal, CartioSpacing.lg)
            }

            // Pinned bottom CTA
            trustSignals
                .padding(.horizontal, CartioSpacing.lg)
                .padding(.bottom, CartioSpacing.lg)
                .padding(.top, CartioSpacing.sm)
        }
        .onAppear {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - Trust Signals

    private var trustSignals: some View {
        VStack(spacing: CartioSpacing.md) {
            TrustSignalsView {
                Task { await viewModel.restorePurchases() }
            }

            Button("Continue with Free") {
                router.completeOnboarding()
            }
            .font(CartioFonts.subheadline())
            .foregroundStyle(CartioColors.textSecondary)
            .accessibilityHint("Skip premium and use the free tier")

            PrimaryButton(
                title: PricingPlans.ctaTitle(for: viewModel.selectedPlan),
                isLoading: viewModel.isPurchasing
            ) {
                Task {
                    await viewModel.purchaseSelectedPlan()
                    if viewModel.error == nil {
                        router.completeOnboarding()
                    } else {
                        showError = true
                    }
                }
            }
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK", role: .cancel) { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Something went wrong.")
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let feature: String
    let freeText: String
    let proText: String

    init(feature: String, free: Bool, pro: Bool) {
        self.feature = feature
        self.freeText = free ? "checkmark" : "xmark"
        self.proText = pro ? "checkmark" : "xmark"
    }

    init(feature: String, free: String, pro: String) {
        self.feature = feature
        self.freeText = free
        self.proText = pro
    }

    var body: some View {
        HStack {
            Text(feature)
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textPrimary)
            Spacer()
            featureValue(freeText).frame(width: 60)
            featureValue(proText).frame(width: 60)
        }
        .padding(.vertical, CartioSpacing.xs)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func featureValue(_ value: String) -> some View {
        if value == "checkmark" {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(CartioColors.success)
        } else if value == "xmark" {
            Image(systemName: "xmark.circle")
                .foregroundStyle(CartioColors.textSecondary.opacity(0.4))
        } else {
            Text(value)
                .font(CartioFonts.footnote())
                .foregroundStyle(CartioColors.textSecondary)
        }
    }
}

// MARK: - Pricing Card

struct PricingCard: View {
    let label: String
    let price: String
    let period: String
    var badge: String?
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? CartioColors.primary : CartioColors.textSecondary.opacity(0.4))
                    .font(.system(size: 22))

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(label).font(CartioFonts.headline())
                            .foregroundStyle(CartioColors.textPrimary)
                        if let badge {
                            Text(badge)
                                .font(CartioFonts.caption())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(CartioColors.secondary)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(period)
                        .font(CartioFonts.caption())
                        .foregroundStyle(CartioColors.textSecondary)
                }
                Spacer()
                Text(price)
                    .font(CartioFonts.title2())
                    .foregroundStyle(isSelected ? CartioColors.primary : CartioColors.textPrimary)
            }
            .padding(CartioSpacing.md)
            .background(CartioColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
            .if(isSelected) { view in
                view.gradientBorder(animated: false)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
