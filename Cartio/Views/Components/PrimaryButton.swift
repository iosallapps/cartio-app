//
//  PrimaryButton.swift
//  Cartio
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            HStack(spacing: CartioSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                }
                Text(title)
                    .font(CartioFonts.headline())
            }
            .frame(maxWidth: .infinity)
            .frame(height: CartioButtonHeight.primary)
            .background(CartioGradient.primaryLinear)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
            .gradientBorder(cornerRadius: CartioRadius.button, colors: [.red, .orange, .purple, .pink, .red], lineWidth: 2.5, continuous: true)
            .shadow(color: CartioColors.primary.opacity(0.25), radius: 10, y: 4)
        }
        .buttonStyle(PrimaryPressStyle())
        .disabled(isLoading)
        .accessibilityValue(isLoading ? "Loading" : "")
    }
}

// MARK: - Press Style

private struct PrimaryPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.08 : 0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
