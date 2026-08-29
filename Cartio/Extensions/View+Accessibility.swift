//
//  View+Accessibility.swift
//  Cartio
//
//  Convenience extensions for accessibility modifiers.
//

import SwiftUI

extension View {

    /// Applies animation only when Reduce Motion is off.
    func reduceMotionAnimation<V: Equatable>(_ animation: Animation?, value: V) -> some View {
        modifier(ReduceMotionModifier(animation: animation, value: value))
    }
}
