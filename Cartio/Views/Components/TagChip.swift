//
//  TagChip.swift
//  Cartio
//

import SwiftUI

struct TagChip: View {
    let name: String
    let colorHex: String

    var body: some View {
        Text(name)
            .font(CartioFonts.caption())
            .padding(.horizontal, CartioSpacing.sm)
            .padding(.vertical, CartioSpacing.xs)
            .background(Color(hex: colorHex).opacity(0.15))
            .foregroundStyle(Color(hex: colorHex))
            .clipShape(Capsule())
            .accessibilityLabel("Tag: \(name)")
    }
}
