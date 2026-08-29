//
//  CardEditorView.swift
//  Cartio
//

import SwiftUI
import SwiftData
import PhotosUI

struct CardEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CardEditorViewModel
    @State private var avatarItem: PhotosPickerItem?
    @State private var logoItem: PhotosPickerItem?
    @State private var showPaywall = false

    init(viewModel: CardEditorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                cardPreview
                editorForm
            }
            .navigationTitle(viewModel.isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                            if !viewModel.showError {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.name.trimmed.isEmpty || viewModel.isSaving)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                if viewModel.isCardLimitError {
                    Button("Upgrade") { showPaywall = true }
                    Button("Cancel", role: .cancel) {}
                } else {
                    Button("OK", role: .cancel) {}
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheet()
            }
        }
    }

    private var cardPreview: some View {
        CardPreviewComponent(
            name: viewModel.name,
            title: viewModel.title,
            company: viewModel.company,
            email: viewModel.email,
            phone: viewModel.phone,
            website: viewModel.website,
            socialLinks: viewModel.socialLinks,
            template: viewModel.selectedTemplate
        )
        .cardShadow()
        .padding(CartioSpacing.md)
        .frame(height: 240)
        .accessibilityLabel("Live card preview")
    }

    private var editorForm: some View {
        Form {
            TemplatePickerSection(
                selectedTemplate: $viewModel.selectedTemplate,
                templates: viewModel.availableTemplates,
                previewName: viewModel.name,
                previewTitle: viewModel.title,
                previewCompany: viewModel.company
            )
            PersonalInfoSection(
                name: $viewModel.name,
                title: $viewModel.title,
                company: $viewModel.company,
                bio: $viewModel.bio
            )
            ContactFieldsSection(
                email: $viewModel.email,
                phone: $viewModel.phone,
                website: $viewModel.website
            )
            SocialLinksSection(socialLinks: $viewModel.socialLinks)
            MediaSection(avatarItem: $avatarItem, logoItem: $logoItem)
        }
        .scrollContentBackground(.hidden)
        .background(CartioColors.background)
        .scrollDismissesKeyboard(.interactively)
    }
}
