//
//  ContactDetailView.swift
//  Cartio
//

import SwiftUI

struct ContactDetailView: View {
    let contact: Contact
    var onSaveToAppleContacts: (() -> Void)?
    var exportService: ContactExportServiceProtocol?
    var subscriptionInteractor: SubscriptionInteractorProtocol?

    @ScaledMetric(relativeTo: .title) private var avatarSize: CGFloat = 80
    @State private var showSavedToast = false
    @State private var showExport = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: CartioSpacing.lg) {
                headerSection
                quickActionsRow
                contactInfoSection
                notesSection
                tagsSection
                metadataSection

                if let onSave = onSaveToAppleContacts {
                    saveToContactsButton(action: onSave)
                }
            }
            .padding(.vertical, CartioSpacing.md)
        }
        .navigationTitle(contact.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if showSavedToast {
                ToastView(message: "Saved to Apple Contacts")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, CartioSpacing.xl)
            }
        }
        .reduceMotionAnimation(.easeInOut(duration: 0.3), value: showSavedToast)
        .sheet(isPresented: $showExport) {
            if let exportService {
                ContactExportSheet(
                    contacts: [contact],
                    exportService: exportService
                )
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallSheet()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: CartioSpacing.sm) {
            let initials = contact.name.split(separator: " ")
                .prefix(2).compactMap(\.first).map(String.init).joined()

            Text(initials.uppercased())
                .font(CartioFonts.title2())
                .foregroundStyle(.white)
                .frame(width: avatarSize, height: avatarSize)
                .background(CartioColors.primary)
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text(contact.name)
                .font(CartioFonts.title3())
                .foregroundStyle(CartioColors.textPrimary)

            if let title = contact.title {
                if let company = contact.company {
                    Text("\(title) at \(company)")
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(CartioColors.textSecondary)
                } else {
                    Text(title)
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(CartioColors.textSecondary)
                }
            } else if let company = contact.company {
                Text(company)
                    .font(CartioFonts.subheadline())
                    .foregroundStyle(CartioColors.textSecondary)
            }

            // Source badge
            HStack(spacing: CartioSpacing.xs) {
                Image(systemName: sourceIcon(contact.source))
                    .font(.system(size: CartioIconSize.xs))
                Text(contact.source.rawValue.capitalized)
                    .font(CartioFonts.caption())
            }
            .foregroundStyle(CartioColors.textSecondary)
            .padding(.horizontal, CartioSpacing.sm)
            .padding(.vertical, CartioSpacing.xs)
            .background(CartioColors.surface)
            .clipShape(Capsule())
            .accessibilityLabel("Added via \(contact.source.rawValue)")
        }
        .sectionPadding()
    }

    // MARK: - Quick Actions

    private var quickActionsRow: some View {
        VStack(spacing: CartioSpacing.sm) {
            HStack(spacing: CartioSpacing.lg) {
                if let phone = contact.phone {
                    quickAction(icon: "phone.fill", label: "Call") {
                        if let url = URL(string: "tel:\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                if let email = contact.email {
                    quickAction(icon: "envelope.fill", label: "Email") {
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                if let phone = contact.phone {
                    quickAction(icon: "message.fill", label: "Message") {
                        if let url = URL(string: "sms:\(phone)") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }

            if exportService != nil {
                HStack(spacing: CartioSpacing.lg) {
                    let locked = !(subscriptionInteractor?.canAccess(.contactExport) ?? false)
                    quickAction(icon: "square.and.arrow.up", label: "Export", locked: locked) {
                        if locked {
                            showPaywall = true
                        } else {
                            showExport = true
                        }
                    }
                }
            }
        }
        .sectionPadding()
    }

    private func quickAction(icon: String, label: String, locked: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: CartioSpacing.xs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.system(size: CartioIconSize.lg))
                    if locked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: CartioIconSize.xs))
                            .foregroundStyle(.white)
                            .padding(CartioSpacing.xs)
                            .background(CartioColors.secondary)
                            .clipShape(Circle())
                            .offset(x: 8, y: -4)
                    }
                }
                Text(label)
                    .font(CartioFonts.caption())
            }
            .foregroundStyle(locked ? CartioColors.textSecondary : CartioColors.primary)
            .frame(maxWidth: .infinity)
            .padding(CartioSpacing.sm)
            .background(CartioColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.button))
        }
        .accessibilityHint("Double tap to \(label.lowercased())")
    }

    // MARK: - Contact Info

    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.sm) {
            SectionHeader(title: "Contact Info")
            if let email = contact.email {
                infoRow(icon: "envelope", value: email)
            }
            if let phone = contact.phone {
                infoRow(icon: "phone", value: phone)
            }
            if let website = contact.website {
                infoRow(icon: "globe", value: website)
            }
        }
        .sectionPadding()
    }

    private func infoRow(icon: String, value: String) -> some View {
        HStack(spacing: CartioSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(CartioColors.primary)
                .frame(width: 24)
            Text(value)
                .font(CartioFonts.body())
                .foregroundStyle(CartioColors.textPrimary)
        }
        .padding(CartioSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CartioColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Notes

    private var notesSection: some View {
        Group {
            if let notes = contact.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: CartioSpacing.sm) {
                    SectionHeader(title: "Notes")
                    Text(notes)
                        .font(CartioFonts.body())
                        .foregroundStyle(CartioColors.textPrimary)
                        .padding(CartioSpacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(CartioColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: CartioRadius.input))
                }
                .sectionPadding()
            }
        }
    }

    // MARK: - Tags

    private var tagsSection: some View {
        Group {
            if !contact.tags.isEmpty {
                VStack(alignment: .leading, spacing: CartioSpacing.sm) {
                    SectionHeader(title: "Tags")
                    FlowLayout(spacing: CartioSpacing.xs) {
                        ForEach(contact.tags) { tag in
                            TagChip(name: tag.name, colorHex: tag.colorHex)
                        }
                    }
                }
                .sectionPadding()
            }
        }
    }

    // MARK: - Metadata

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: CartioSpacing.xs) {
            SectionHeader(title: "Details")
            HStack {
                Text("Added")
                    .font(CartioFonts.caption())
                    .foregroundStyle(CartioColors.textSecondary)
                Spacer()
                Text(contact.createdAt.shortFormatted)
                    .font(CartioFonts.caption())
                    .foregroundStyle(CartioColors.textSecondary)
            }
            if contact.isFavorite {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(CartioColors.warning)
                        .font(.system(size: CartioIconSize.sm))
                    Text("Favorite")
                        .font(CartioFonts.caption())
                        .foregroundStyle(CartioColors.textSecondary)
                }
            }
        }
        .sectionPadding()
    }

    // MARK: - Save to Apple Contacts

    private func saveToContactsButton(action: @escaping () -> Void) -> some View {
        SecondaryButton(title: "Save to Apple Contacts") {
            action()
            Haptics.success()
            showSavedToast = true
            Task {
                try? await Task.sleep(for: .seconds(2))
                showSavedToast = false
            }
        }
        .sectionPadding()
        .padding(.bottom, CartioSpacing.lg)
    }

    // MARK: - Helpers

    private func sourceIcon(_ source: ContactSource) -> String {
        switch source {
        case .scanned: return "camera"
        case .shared: return "square.and.arrow.down"
        case .manual: return "pencil"
        case .imported: return "person.crop.circle.badge.plus"
        }
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
