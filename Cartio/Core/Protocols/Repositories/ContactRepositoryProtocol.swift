//
//  ContactRepositoryProtocol.swift
//  Cartio
//

import Foundation

struct ContactFilter {
    var searchQuery: String?
    var tagIDs: [UUID]?
    var isFavorite: Bool?
    var source: ContactSource?
}

@MainActor
protocol ContactRepositoryProtocol {
    func fetchAll(filter: ContactFilter?) async throws -> [Contact]
    func search(query: String) async throws -> [Contact]
    func save(_ contact: Contact) async throws
    func saveAll(_ contacts: [Contact]) async throws
    func delete(_ contact: Contact) async throws
    func findDuplicates(for contact: Contact) async throws -> [Contact]

    // MARK: - Tags
    func fetchTags() async throws -> [ContactTag]
    func createTag(name: String, colorHex: String) async throws -> ContactTag
    func deleteTag(_ tag: ContactTag) async throws
}
