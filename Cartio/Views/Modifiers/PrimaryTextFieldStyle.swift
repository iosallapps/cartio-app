//
//  PrimaryTextFieldStyle.swift
//  Cartio
//

import SwiftUI

struct CartioTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(CartioFonts.body())
            .padding(CartioSpacing.sm)
            .background(CartioColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
            .foregroundStyle(CartioColors.textPrimary)
    }
}
