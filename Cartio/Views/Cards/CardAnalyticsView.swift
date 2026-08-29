//
//  CardAnalyticsView.swift
//  Cartio
//
//  Basic per-card stats — visible to all users (free tier).
//

import SwiftUI

struct CardAnalyticsView: View {
    let summary: AnalyticsSummary

    var body: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Activity")

            HStack(spacing: CartioSpacing.md) {
                statItem(icon: "eye", value: summary.totalViews, label: "Views")
                statItem(icon: "square.and.arrow.up", value: summary.totalShares, label: "Shares")
                statItem(icon: "square.and.arrow.down", value: summary.totalSaves, label: "Saves")
            }
        }
    }

    private func statItem(icon: String, value: Int, label: String) -> some View {
        VStack(spacing: CartioSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(CartioColors.primary)
            Text("\(value)")
                .font(CartioFonts.headline())
                .foregroundStyle(CartioColors.textPrimary)
            Text(label)
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(CartioSpacing.sm)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
    }
}
