//
//  AnalyticsDashboardView.swift
//  Cartio
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    @State var viewModel: ProfileViewModel
    @State private var selectedPeriod: AnalyticsPeriod = .thirtyDays

    var body: some View {
        ScrollView {
            VStack(spacing: CartioSpacing.lg) {
                periodPicker
                summaryCards

                if viewModel.isPremium {
                    viewsChart
                    shareMethodSection
                    topLinksSection
                } else {
                    ZStack {
                        VStack(spacing: CartioSpacing.lg) {
                            sampleViewsChart
                            sampleShareMethodSection
                            sampleTopLinksSection
                        }
                        .blur(radius: 6)
                        .allowsHitTesting(false)

                        FeatureGateOverlay(
                            title: "Advanced Analytics",
                            message: "Upgrade to Pro for charts, conversion rates, and share breakdowns."
                        ) {
                            viewModel.showSubscription = true
                        }
                    }
                }
            }
            .sectionPadding()
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadAnalytics(period: selectedPeriod) }
        .onChange(of: selectedPeriod) {
            Task { await viewModel.loadAnalytics(period: selectedPeriod) }
        }
    }

    // MARK: - Period Picker

    private var periodPicker: some View {
        HStack(spacing: CartioSpacing.sm) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Button {
                    selectedPeriod = period
                } label: {
                    Text(period.rawValue)
                        .font(CartioFonts.caption())
                        .padding(.horizontal, CartioSpacing.sm)
                        .padding(.vertical, CartioSpacing.xs)
                        .background(selectedPeriod == period ? CartioColors.primary : CartioColors.surface)
                        .foregroundStyle(selectedPeriod == period ? .white : CartioColors.textPrimary)
                        .clipShape(Capsule())
                }
                .accessibilityAddTraits(selectedPeriod == period ? .isSelected : [])
            }
        }
    }

    // MARK: - Summary Cards

    private var summaryCards: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible())]
        let analytics = viewModel.analytics
        let conversion = String(
            format: "%.1f%%",
            (analytics?.conversionRate ?? 0) * 100
        )
        return LazyVGrid(columns: columns, spacing: CartioSpacing.md) {
            statCard(title: "Views", value: "\(analytics?.totalViews ?? 0)", icon: "eye", trend: nil)
            statCard(title: "Saves", value: "\(analytics?.totalSaves ?? 0)", icon: "square.and.arrow.down", trend: nil)
            statCard(title: "Shares", value: "\(analytics?.totalShares ?? 0)", icon: "square.and.arrow.up", trend: nil)
            statCard(title: "Conversion", value: conversion, icon: "arrow.up.right", trend: nil)
        }
    }

    private func statCard(title: String, value: String, icon: String, trend: Double?) -> some View {
        VStack(spacing: CartioSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: CartioIconSize.lg))
                .foregroundStyle(CartioColors.primary)
            Text(value)
                .font(CartioFonts.title3())
                .foregroundStyle(CartioColors.textPrimary)
            Text(title)
                .font(CartioFonts.caption())
                .foregroundStyle(CartioColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Views Chart

    private var viewsChart: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Views Over Time")

            if let data = viewModel.analytics?.viewsByDay, !data.isEmpty {
                Chart {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, count in
                        LineMark(x: .value("Date", date), y: .value("Views", count))
                            .foregroundStyle(CartioColors.primary)
                        AreaMark(x: .value("Date", date), y: .value("Views", count))
                            .foregroundStyle(CartioColors.primary.opacity(0.1))
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .accessibilityLabel("Views chart showing trend over selected period")
            } else {
                emptyChartPlaceholder
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
    }

    // MARK: - Top Links

    private var topLinksSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Link Tap Breakdown")

            if let topLinks = viewModel.analytics?.topLinks, !topLinks.isEmpty {
                ForEach(topLinks.sorted(by: { $0.value > $1.value }).prefix(5), id: \.key) { link, count in
                    HStack {
                        Text(link)
                            .font(CartioFonts.body())
                            .foregroundStyle(CartioColors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("\(count)")
                            .font(CartioFonts.headline())
                            .foregroundStyle(CartioColors.primary)
                    }
                    .padding(.vertical, CartioSpacing.xs)
                }
            } else {
                Text("No link tap data yet")
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.textSecondary)
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
    }

    // MARK: - Share Methods

    private var shareMethodSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Share Methods")

            if let devices = viewModel.analytics?.deviceBreakdown, !devices.isEmpty {
                // Reuse deviceBreakdown to show share method data
                ForEach(devices.sorted(by: { $0.value > $1.value }), id: \.key) { method, count in
                    HStack {
                        Text(method)
                            .font(CartioFonts.body())
                            .foregroundStyle(CartioColors.textPrimary)
                        Spacer()
                        Text("\(count)")
                            .font(CartioFonts.headline())
                            .foregroundStyle(CartioColors.primary)
                    }
                    .padding(.vertical, CartioSpacing.xs)
                }
            } else {
                Text("No share data yet")
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.textSecondary)
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
    }

    // MARK: - Sample Teaser (Non-Premium)

    private var sampleViewsChart: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Views Over Time")

            Chart {
                ForEach(sampleChartData, id: \.day) { item in
                    LineMark(x: .value("Date", item.day), y: .value("Views", item.value))
                        .foregroundStyle(CartioColors.primary)
                    AreaMark(x: .value("Date", item.day), y: .value("Views", item.value))
                        .foregroundStyle(CartioColors.primary.opacity(0.1))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
        .accessibilityHidden(true)
    }

    private var sampleShareMethodSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Share Methods")

            ForEach(sampleShareData, id: \.method) { item in
                HStack {
                    Text(item.method)
                        .font(CartioFonts.body())
                        .foregroundStyle(CartioColors.textPrimary)
                    Spacer()
                    Text("\(item.count)")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.primary)
                }
                .padding(.vertical, CartioSpacing.xs)
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
        .accessibilityHidden(true)
    }

    private var sampleTopLinksSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Link Tap Breakdown")

            ForEach(sampleLinkData, id: \.link) { item in
                HStack {
                    Text(item.link)
                        .font(CartioFonts.body())
                        .foregroundStyle(CartioColors.textPrimary)
                        .lineLimit(1)
                    Spacer()
                    Text("\(item.count)")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.primary)
                }
                .padding(.vertical, CartioSpacing.xs)
            }
        }
        .padding(CartioSpacing.md)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
        .accessibilityHidden(true)
    }

    private var sampleChartData: [(day: String, value: Int)] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].enumerated().map { index, day in
            (day: day, value: [12, 18, 15, 24, 30, 22, 28][index])
        }
    }

    private var sampleShareData: [(method: String, count: Int)] {
        [("QR Code", 42), ("NFC", 18), ("Link", 31), ("AirDrop", 9)]
    }

    private var sampleLinkData: [(link: String, count: Int)] {
        [("LinkedIn", 67), ("Twitter", 43), ("Portfolio", 28), ("Email", 15)]
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: CartioSpacing.sm) {
            Image(systemName: "chart.line.downtrend.xyaxis")
                .font(.system(size: CartioIconSize.xxl))
                .foregroundStyle(CartioColors.textSecondary.opacity(0.4))
            Text("No data available yet")
                .font(CartioFonts.subheadline())
                .foregroundStyle(CartioColors.textSecondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }
}
