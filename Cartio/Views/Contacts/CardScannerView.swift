//
//  CardScannerView.swift
//  Cartio
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct CardScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CardScannerViewModel
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(viewModel: CardScannerViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                cameraSection
                extractedFieldsForm
            }
            .navigationTitle("Scan Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.saveContact(context: modelContext)
                            if viewModel.error == nil {
                                Haptics.medium()
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.name.trimmed.isEmpty || viewModel.isSaving)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                if let newItem {
                    Task { await loadAndScan(item: newItem) }
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred.")
            }
        }
    }

    // MARK: - Camera Section

    private var cameraSection: some View {
        ZStack {
            CartioColors.surface

            if viewModel.isScanning {
                VStack(spacing: CartioSpacing.md) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Scanning...")
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(CartioColors.textSecondary)
                }
                .accessibilityLabel("Scanning business card in progress")
            } else if viewModel.scannedImage != nil {
                VStack(spacing: CartioSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: CartioIconSize.hero))
                        .foregroundStyle(CartioColors.success)
                    Text("Card scanned! Review the fields below.")
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(CartioColors.textSecondary)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("Scan Another")
                            .font(CartioFonts.caption())
                            .foregroundStyle(CartioColors.primary)
                    }
                }
                .accessibilityLabel("Card scan complete. Review the extracted fields below.")
            } else {
                VStack(spacing: CartioSpacing.md) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: CartioIconSize.display))
                        .foregroundStyle(CartioColors.textSecondary)

                    Text("Take or select a photo of a business card")
                        .font(CartioFonts.subheadline())
                        .foregroundStyle(CartioColors.textSecondary)
                        .multilineTextAlignment(.center)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(CartioFonts.body())
                            .foregroundStyle(.white)
                            .padding(.horizontal, CartioSpacing.lg)
                            .padding(.vertical, CartioSpacing.sm)
                            .background(CartioColors.primary)
                            .clipShape(Capsule())
                    }
                }
                .accessibilityLabel("No card scanned. Choose a photo of a business card to scan.")
            }
        }
        .frame(height: 220)
    }

    // MARK: - Extracted Fields

    private var extractedFieldsForm: some View {
        Form {
            Section("Extracted Info") {
                TextField("Name *", text: $viewModel.name)
                TextField("Title", text: $viewModel.extractedTitle)
                TextField("Company", text: $viewModel.extractedCompany)
                TextField("Email", text: $viewModel.extractedEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                TextField("Phone", text: $viewModel.extractedPhone)
                    .keyboardType(.phonePad)
                TextField("Website", text: $viewModel.extractedWebsite)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
            }

            if !viewModel.duplicates.isEmpty {
                Section {
                    Label("Possible duplicate found: \(viewModel.duplicates.first?.name ?? "")", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(CartioColors.warning)
                        .font(CartioFonts.footnote())
                } header: {
                    Text("Duplicate Warning")
                }
            }

            Section("Notes") {
                TextField("Add notes...", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .scrollContentBackground(.hidden)
        .background(CartioColors.background)
    }

    // MARK: - Photo Loading

    private func loadAndScan(item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await viewModel.scanImage(image)
        await viewModel.checkDuplicates()
        if !viewModel.duplicates.isEmpty {
            UIAccessibility.post(notification: .announcement, argument: "Possible duplicate contact found: \(viewModel.duplicates.first?.name ?? "")")
        }
    }
}
