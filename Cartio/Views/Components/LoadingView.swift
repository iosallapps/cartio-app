//
//  LoadingView.swift
//  Cartio
//

import SwiftUI

struct LoadingView: View {
    var message: String?

    var body: some View {
        VStack(spacing: CartioSpacing.md) {
            ProgressView()
                .tint(CartioColors.primary)

            if let message {
                Text(message)
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CartioColors.background)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message ?? "Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }
}
