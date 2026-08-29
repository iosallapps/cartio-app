//
//  PricingCardsView.swift
//  Cartio
//
//  Shared pricing card selector used by PremiumPitchView and PaywallSheet.
//

import SwiftUI

// MARK: - Pricing Plan Data

struct PricingPlan: Identifiable {
    let id: String
    let label: String
    let price: String
    let period: String
    var badge: String?
}

enum PricingPlans {
    static let all: [PricingPlan] = [
        PricingPlan(
            id: AppConstants.Products.proMonthly,
            label: "Monthly",
            price: "$6.99",
            period: "/month"
        ),
        PricingPlan(
            id: AppConstants.Products.proYearly,
            label: "Yearly",
            price: "$49.99",
            period: "/year",
            badge: "Save 40%"
        ),
        PricingPlan(
            id: AppConstants.Products.proLifetime,
            label: "Lifetime",
            price: "$99.99",
            period: "one-time"
        )
    ]

    /// Returns the CTA title for a given product ID.
    static func ctaTitle(for productID: String) -> String {
        switch productID {
        case AppConstants.Products.proMonthly: return "Subscribe Monthly"
        case AppConstants.Products.proYearly: return "Start Free Trial"
        case AppConstants.Products.proLifetime: return "Buy Lifetime"
        default: return "Start Free Trial"
        }
    }
}

// MARK: - Pricing Cards View

struct PricingCardsView: View {
    @Binding var selectedPlan: String
    var plans: [PricingPlan] = PricingPlans.all

    var body: some View {
        VStack(spacing: CartioSpacing.md) {
            ForEach(plans) { plan in
                PricingCard(
                    label: plan.label,
                    price: plan.price,
                    period: plan.period,
                    badge: plan.badge,
                    isSelected: selectedPlan == plan.id
                ) {
                    Haptics.selection()
                    selectedPlan = plan.id
                }
            }
        }
    }
}
