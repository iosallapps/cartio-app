import SwiftUI

/// Animated mesh gradient background for Cartio — teal/cyan brand palette.
struct CartioMeshBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 15.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            MeshGradient(
                width: 3, height: 3,
                points: [
                    .init(0, 0), .init(Float(0.5 + 0.04 * sin(t * 0.6)), 0), .init(1, 0),
                    .init(0, Float(0.5 + 0.03 * cos(t * 0.4))),
                    .init(Float(0.5 + 0.05 * cos(t * 0.7)), Float(0.5 + 0.05 * sin(t * 0.5))),
                    .init(1, Float(0.5 + 0.03 * sin(t * 0.8))),
                    .init(0, 1), .init(Float(0.5 + 0.04 * cos(t * 0.5)), 1), .init(1, 1)
                ],
                colors: [
                    CartioColors.primary.opacity(0.10), Color(red: 0.15, green: 0.65, blue: 0.85).opacity(0.06), .clear,
                    Color(red: 0.4, green: 0.3, blue: 0.85).opacity(0.05), .clear, CartioColors.primary.opacity(0.08),
                    .clear, Color(red: 0.15, green: 0.65, blue: 0.85).opacity(0.05), .clear
                ]
            )
        }
        .ignoresSafeArea()
    }
}
