//
//  SectionPaddingModifier.swift
//  Cartio
//

import SwiftUI

struct SectionPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, CartioSpacing.md)
    }
}
