//
//  ContactListView.swift
//  Cartio
//

import SwiftUI
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext
    @ScaledMetric(relativeTo: .body) private var initialsSize: CGFloat = 40
    @State private var viewModel: ContactsViewModel
    @State private var showImportAlert = false
    @State private var showExport = false
    @State private var showPaywall = false

    init(viewModel: ContactsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CartioMeshBackground()

                Group {
                    if viewModel.contacts.isEmpty && !viewModel.isLoading {
                        EmptyStateView(
                            icon: "person.2",
                            title: "No Contacts",
                            message: "Scan a business card or import from your phone.",
                            buttonTitle: "Scan Card"
                        ) {
                            viewModel.showScanner = true
                        }
                    } else {
                        contactList
                    }
                }
            }
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchQuery, prompt: "Search contacts")
            .onChange(of: viewModel.searchQuery) { _, _ in
                Task { await viewModel.loadContacts() }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Contacts")
                        .font(CartioFonts.headline())
                        .foregroundStyle(CartioColors.textPrimary)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            viewModel.showScanner = true
                        } label: {
                            Label("Scan Card", systemImage: "camera")
                        }
                        Button {
                            viewModel.showAddContact = true
                        } label: {
                            Label("Add Manually", systemImage: "plus")
                        }
                        Button {
                            Task { await viewModel.importAppleContacts() }
                        } label: {
                            Label("Import Contacts", systemImage: "person.crop.circle.badge.plus")
                        }
                        if !viewModel.contacts.isEmpty {
                            Divider()
                            Button {
                                showExport = true
                            } label: {
                                Label("Export All", systemImage: "square.and.arrow.up")
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .task { await viewModel.loadContacts() }
            .refreshable { await viewModel.loadContacts() }
            .overlay {
                if viewModel.isLoading && viewModel.contacts.isEmpty {
                    LoadingView()
                }
            }
            .sheet(isPresented: $viewModel.showScanner, onDismiss: {
                Task { await viewModel.loadContacts() }
            }) {
                CardScannerView(
                    viewModel: DependencyContainer.shared.makeCardScannerViewModel(modelContext: modelContext)
                )
            }
            .sheet(isPresented: $viewModel.showAddContact, onDismiss: {
                Task { await viewModel.loadContacts() }
            }) {
                ManualContactSheet(contactInteractor: viewModel.contactInteractorRef)
            }
            .alert("Import Complete", isPresented: $viewModel.showImportSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Imported \(viewModel.importedCount) contacts from your phone.")
            }
            .sheet(isPresented: $showExport) {
                ContactExportSheet(
                    contacts: viewModel.contacts,
                    exportService: DependencyContainer.shared.contactExportService
                )
            }
            .sheet(isPresented: $showPaywall) {
                PaywallSheet()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.error?.localizedDescription ?? "An error occurred.")
            }
        }
    }

    private var contactList: some View {
        List {
            filterChips

            ForEach(viewModel.contacts) { contact in
                NavigationLink(value: contact) {
                    contactRow(contact)
                }
            }
            .onDelete { indexSet in
                Task {
                    for index in indexSet {
                        await viewModel.deleteContact(viewModel.contacts[index])
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationDestination(for: Contact.self) { contact in
            ContactDetailView(
                contact: contact,
                onSaveToAppleContacts: {
                    Task { await viewModel.saveToAppleContacts(contact) }
                },
                exportService: DependencyContainer.shared.contactExportService,
                subscriptionInteractor: DependencyContainer.shared.makeSubscriptionInteractor()
            )
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CartioSpacing.sm) {
                ForEach(ContactListFilter.allCases, id: \.self) { filter in
                    Button {
                        viewModel.selectedFilter = filter
                        Task { await viewModel.loadContacts() }
                    } label: {
                        Text(filter.rawValue)
                            .font(CartioFonts.caption())
                            .padding(.horizontal, CartioSpacing.sm)
                            .padding(.vertical, CartioSpacing.xs)
                            .background(viewModel.selectedFilter == filter ? CartioColors.primary : CartioColors.surface)
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : CartioColors.textPrimary)
                            .clipShape(Capsule())
                            .accessibilityAddTraits(viewModel.selectedFilter == filter ? .isSelected : [])
                    }
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private func contactRow(_ contact: Contact) -> some View {
        HStack(spacing: CartioSpacing.md) {
            initialsCircle(for: contact)

            VStack(alignment: .leading, spacing: CartioSpacing.xs) {
                Text(contact.name)
                    .font(CartioFonts.body())
                    .foregroundStyle(CartioColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: CartioSpacing.xs) {
                    if let company = contact.company {
                        Text(company)
                            .font(CartioFonts.caption())
                            .foregroundStyle(CartioColors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if contact.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(CartioColors.warning)
                        .font(.system(size: CartioIconSize.sm))
                }
                sourceBadge(contact.source)
            }
        }
        .padding(.vertical, CartioSpacing.xs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(contact.name)\(contact.company.map { ", \($0)" } ?? "")\(contact.isFavorite ? ", favorite" : "")")
        .accessibilityHint("Double tap to view details")
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task { await viewModel.deleteContact(contact) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                Task { await viewModel.toggleFavorite(contact) }
            } label: {
                Label(
                    contact.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: contact.isFavorite ? "star.slash" : "star.fill"
                )
            }
            .tint(CartioColors.warning)
        }
    }

    private func sourceBadge(_ source: ContactSource) -> some View {
        Text(source.rawValue.capitalized)
            .font(CartioFonts.caption())
            .foregroundStyle(CartioColors.textSecondary)
            .padding(.horizontal, CartioSpacing.xs)
            .padding(.vertical, CartioSpacing.xs)
            .background(CartioColors.surface)
            .clipShape(Capsule())
    }

    private func initialsCircle(for contact: Contact) -> some View {
        let initials = contact.name.split(separator: " ")
            .prefix(2)
            .compactMap(\.first)
            .map(String.init)
            .joined()

        return Text(initials.uppercased())
            .font(CartioFonts.caption())
            .foregroundStyle(.white)
            .frame(width: initialsSize, height: initialsSize)
            .background(CartioColors.primary)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }
}
