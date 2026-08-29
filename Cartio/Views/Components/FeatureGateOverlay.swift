//
//  FeatureGateOverlay.swift
//  Cartio
//
//  "Unlock with Pro" overlay for gated features.
//  Reusable on every premium-locked screen.
//

import SwiftUI

struct FeatureGateOverlay: View {
    var title: String = "Pro Feature"
    var message: String = "Upgrade to Pro to unlock this feature."
    var action: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(CartioOpacity.overlay)
                .ignoresSafeArea()

            VStack(spacing: CartioSpacing.lg) {
                Image(systemName: "lock.fill")
                    .font(.system(size: CartioIconSize.hero))
                    .foregroundStyle(CartioColors.primary)

                // Intentional: white text on dark overlay works in both light and dark modes
                Text(title)
                    .font(CartioFonts.title3())
                    .foregroundStyle(CartioColors.background)

                Text(message)
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.background.opacity(0.8))
                    .multilineTextAlignment(.center)

                PrimaryButton(title: "Unlock with Pro", action: action)
                    .frame(maxWidth: 220)
            }
            .padding(CartioSpacing.xl)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message). Requires Pro subscription.")
    }
}
