//
//  ReduceMotionModifier.swift
//  Cartio
//
//  Conditionally disables animation when Reduce Motion is enabled.
//

import SwiftUI

struct ReduceMotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? nil : animation, value: value)
    }
}
