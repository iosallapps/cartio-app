//
//  ContactExportSheet.swift
//  Cartio
//

import SwiftUI

struct ContactExportSheet: View {
    let contacts: [Contact]
    let exportService: ContactExportServiceProtocol
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFormat: ExportFormat = .vcf
    @State private var isExporting = false
    @State private var exportedURL: URL?
    @State private var showShareSheet = false
    @State private var error: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: CartioSpacing.lg) {
                // Header
                VStack(spacing: CartioSpacing.sm) {
                    Image(systemName: "square.and.arrow.up.on.square")
                        .font(.system(size: CartioIconSize.xxl))
                        .foregroundStyle(CartioColors.primary)

                    Text("Export \(contacts.count) Contact\(contacts.count == 1 ? "" : "s")")
                        .font(CartioFonts.title3())
                        .foregroundStyle(CartioColors.textPrimary)
                }
                .padding(.top, CartioSpacing.lg)

                // Format picker
                VStack(alignment: .leading, spacing: CartioSpacing.sm) {
                    Text("Format")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.textPrimary)

                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        Button {
                            selectedFormat = format
                        } label: {
                            HStack {
                                Image(systemName: selectedFormat == format ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedFormat == format ? CartioColors.primary : CartioColors.textSecondary.opacity(0.4))
                                VStack(alignment: .leading) {
                                    Text(format.rawValue)
                                        .font(CartioFonts.body())
                                        .foregroundStyle(CartioColors.textPrimary)
                                    Text(format == .vcf ? "Compatible with all contact apps" : "Spreadsheet-friendly format")
                                        .font(CartioFonts.caption())
                                        .foregroundStyle(CartioColors.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(CartioSpacing.md)
                            .background(CartioColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: CartioRadius.card))
                            .overlay(
                                RoundedRectangle(cornerRadius: CartioRadius.card)
                                    .stroke(selectedFormat == format ? CartioColors.primary : .clear, lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CartioSpacing.lg)

                Spacer()

                if let error {
                    Text(error)
                        .font(CartioFonts.caption())
                        .foregroundStyle(CartioColors.error)
                }

                PrimaryButton(title: "Export", isLoading: isExporting) {
                    exportContacts()
                }
                .padding(.horizontal, CartioSpacing.lg)
                .padding(.bottom, CartioSpacing.md)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = exportedURL {
                    ShareSheet(items: [url])
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func exportContacts() {
        isExporting = true
        error = nil
        do {
            let url = try exportService.export(contacts: contacts, format: selectedFormat)
            exportedURL = url
            isExporting = false
            showShareSheet = true
        } catch {
            self.error = "Export failed. Please try again."
            isExporting = false
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
