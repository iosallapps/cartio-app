//
//  ContactsViewModel.swift
//  Cartio
//

import Foundation

@Observable
final class ContactsViewModel {

    var contacts: [Contact] = []
    var searchQuery = ""
    var selectedFilter: ContactListFilter = .all
    var showScanner = false
    var showAddContact = false
    var showImportSuccess = false
    var showError = false
    var importedCount = 0
    var isLoading = false
    var error: CartioError?

    // Exposed for ManualContactSheet
    var contactInteractorRef: ContactInteractorProtocol { contactInteractor }

    private let contactInteractor: ContactInteractorProtocol

    init(contactInteractor: ContactInteractorProtocol) {
        self.contactInteractor = contactInteractor
    }

    func loadContacts(context: Any? = nil) async {
        isLoading = true
        defer { isLoading = false }

        do {
            if !searchQuery.isEmpty {
                contacts = try await contactInteractor.searchContacts(query: searchQuery)
            } else {
                var filter: ContactFilter?
                switch selectedFilter {
                case .all: filter = nil
                case .favorites: filter = ContactFilter(isFavorite: true)
                case .recent: filter = nil // sorted by date
                }
                contacts = try await contactInteractor.fetchContacts(filter: filter)

                if selectedFilter == .recent {
                    contacts.sort { $0.createdAt > $1.createdAt }
                    contacts = Array(contacts.prefix(20))
                }
            }
        } catch let err as CartioError {
            error = err
            showError = true
        } catch {
            self.error = .unknown(error.localizedDescription)
            showError = true
        }
    }

    func deleteContact(_ contact: Contact, context: Any? = nil) async {
        do {
            try await contactInteractor.deleteContact(contact)
            await loadContacts()
        } catch let err as CartioError {
            error = err
            showError = true
        } catch {
            self.error = .unknown(error.localizedDescription)
            showError = true
        }
    }

    func toggleFavorite(_ contact: Contact) async {
        contact.isFavorite.toggle()
        contact.updatedAt = .now
        do {
            try await contactInteractor.saveContact(contact)
        } catch {
            // Revert on failure
            contact.isFavorite.toggle()
            contact.updatedAt = .now
            self.error = .unknown(error.localizedDescription)
            showError = true
        }
    }

    func importAppleContacts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let imported = try await contactInteractor.importFromAppleContacts()
            try await contactInteractor.saveContacts(imported)
            importedCount = imported.count
            showImportSuccess = true
            await loadContacts()
        } catch let err as CartioError {
            error = err
            showError = true
        } catch {
            self.error = .unknown(error.localizedDescription)
            showError = true
        }
    }

    func saveToAppleContacts(_ contact: Contact) async {
        // This would need a BusinessCard conversion or direct CNContact save
        // For now, the detail view handles this
    }
}

enum ContactListFilter: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case recent = "Recent"
}
