import SwiftUI

/// Glassmorphism card modifier — .ultraThinMaterial with subtle border and shadow.
struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat = CartioRadius.card

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = CartioRadius.card) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius))
    }
}
