//
//  CardListView.swift
//  Cartio
//

import SwiftUI
import SwiftData

struct CardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @State private var viewModel: CardsViewModel

    init(viewModel: CardsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CartioMeshBackground()

                Group {
                    if viewModel.cards.isEmpty && !viewModel.isLoading {
                        EmptyStateView(
                            icon: "rectangle.on.rectangle",
                            title: "No Cards Yet",
                            message: "Create your first digital business card.",
                            buttonTitle: "Create Card"
                        ) {
                            viewModel.showEditor = true
                        }
                    } else {
                        cardGrid
                    }
                }
            }
            .navigationTitle("My Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Cards")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.textPrimary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.editingCard = nil
                        viewModel.showEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Create new card")
                }
            }
            .task { await viewModel.loadCards() }
            .refreshable { await viewModel.loadCards() }
            .overlay {
                if viewModel.isLoading && viewModel.cards.isEmpty {
                    LoadingView()
                }
            }
            .navigationDestination(item: $viewModel.selectedCard) { card in
                CardDetailView(
                    card: card,
                    onEdit: {
                        viewModel.editingCard = card
                        viewModel.showEditor = true
                    },
                    onShare: {
                        router.selectedTab = .share
                    },
                    onDelete: {
                        Task {
                            await viewModel.deleteCard(card)
                            viewModel.selectedCard = nil
                        }
                    },
                    analyticsInteractor: DependencyContainer.shared.makeAnalyticsInteractor(modelContext: modelContext)
                )
            }
            .fullScreenCover(isPresented: $viewModel.showEditor, onDismiss: {
                Task { await viewModel.loadCards() }
            }) {
                CardEditorView(
                    viewModel: DependencyContainer.shared.makeCardEditorViewModel(
                        modelContext: modelContext,
                        card: viewModel.editingCard
                    )
                )
            }
        }
    }

    private var cardGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CartioSpacing.md) {
                ForEach(viewModel.cards) { card in
                    cardCell(card)
                }
            }
            .sectionPadding()
            .padding(.top, CartioSpacing.sm)
        }
    }

    private func cardCell(_ card: BusinessCard) -> some View {
        CardPreviewComponent(card: card)
            .frame(minHeight: 180)
            .cardShadow()
            .overlay(alignment: .topTrailing) {
                if card.isDefault {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(CartioColors.success)
                        .font(.system(size: CartioIconSize.md))
                        .padding(CartioSpacing.sm)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(card.name)\(card.isDefault ? ", default card" : "")")
            .accessibilityHint("Double tap to view details. Long press for more options.")
            .onTapGesture { viewModel.selectedCard = card }
            .contextMenu {
                Button {
                    viewModel.editingCard = card
                    viewModel.showEditor = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button {
                    router.selectedTab = .share
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                if !card.isDefault {
                    Button {
                        Task { await viewModel.setDefault(card) }
                    } label: {
                        Label("Set as Default", systemImage: "checkmark.circle")
                    }
                }

                Divider()

                Button(role: .destructive) {
                    Task { await viewModel.deleteCard(card) }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}
