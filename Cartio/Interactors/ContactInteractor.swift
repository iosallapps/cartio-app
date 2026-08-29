//
//  ContactInteractor.swift
//  Cartio
//

import Foundation

final class ContactInteractor: ContactInteractorProtocol {

    private let repository: ContactRepositoryProtocol
    private let appleContactsService: AppleContactsServiceProtocol

    init(repository: ContactRepositoryProtocol, appleContactsService: AppleContactsServiceProtocol) {
        self.repository = repository
        self.appleContactsService = appleContactsService
    }

    func fetchContacts(filter: ContactFilter?) async throws -> [Contact] {
        try await repository.fetchAll(filter: filter)
    }

    func searchContacts(query: String) async throws -> [Contact] {
        try await repository.search(query: query)
    }

    func saveContact(_ contact: Contact) async throws {
        try await repository.save(contact)
    }

    func saveContacts(_ contacts: [Contact]) async throws {
        try await repository.saveAll(contacts)
    }

    func deleteContact(_ contact: Contact) async throws {
        try await repository.delete(contact)
    }

    func detectDuplicates(for contact: Contact) async throws -> [Contact] {
        try await repository.findDuplicates(for: contact)
    }

    func importFromAppleContacts() async throws -> [Contact] {
        let granted = try await appleContactsService.requestAccess()
        guard granted else { throw CartioError.contactsPermissionDenied }
        return try await appleContactsService.fetchContacts()
    }

    // MARK: - Tags

    func fetchTags() async throws -> [ContactTag] {
        try await repository.fetchTags()
    }

    @discardableResult
    func createTag(name: String, colorHex: String) async throws -> ContactTag {
        try await repository.createTag(name: name, colorHex: colorHex)
    }

    func deleteTag(_ tag: ContactTag) async throws {
        try await repository.deleteTag(tag)
    }
}
