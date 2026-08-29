//
//  SectionHeader.swift
//  Cartio
//

import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(CartioFonts.footnote())
            .foregroundStyle(CartioColors.textSecondary)
            .textCase(.uppercase)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}
