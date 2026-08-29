//
//  CardShadowModifier.swift
//  Cartio
//

import SwiftUI

struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
