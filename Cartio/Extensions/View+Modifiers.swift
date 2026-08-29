//
//  View+Modifiers.swift
//  Cartio
//

import SwiftUI

extension View {
    func cardShadow() -> some View {
        modifier(CardShadowModifier())
    }

    func sectionPadding() -> some View {
        modifier(SectionPaddingModifier())
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
