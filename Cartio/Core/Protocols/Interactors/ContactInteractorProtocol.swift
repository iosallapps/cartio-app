//
//  ContactInteractorProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol ContactInteractorProtocol {
    func fetchContacts(filter: ContactFilter?) async throws -> [Contact]
    func searchContacts(query: String) async throws -> [Contact]
    func saveContact(_ contact: Contact) async throws
    func saveContacts(_ contacts: [Contact]) async throws
    func deleteContact(_ contact: Contact) async throws
    func detectDuplicates(for contact: Contact) async throws -> [Contact]
    func importFromAppleContacts() async throws -> [Contact]

    // MARK: - Tags
    func fetchTags() async throws -> [ContactTag]
    func createTag(name: String, colorHex: String) async throws -> ContactTag
    func deleteTag(_ tag: ContactTag) async throws
}
