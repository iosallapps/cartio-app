//
//  SecondaryButton.swift
//  Cartio
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Text(title)
                .font(CartioFonts.headline())
                .frame(maxWidth: .infinity)
                .frame(height: CartioButtonHeight.secondary)
                .foregroundStyle(CartioColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
                .gradientBorder(cornerRadius: CartioRadius.button, animated: false)
        }
        .buttonStyle(SecondaryPressStyle())
    }
}

// MARK: - Press Style

private struct SecondaryPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
