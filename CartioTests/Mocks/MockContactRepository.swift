//
//  MockContactRepository.swift
//  CartioTests
//

import Foundation
@testable import Cartio

@MainActor
final class MockContactRepository: ContactRepositoryProtocol {

    var contacts: [Contact] = []
    var shouldThrow = false
    var duplicates: [Contact] = []

    func fetchAll(filter: ContactFilter?) async throws -> [Contact] {
        if shouldThrow { throw CartioError.unknown("mock error") }
        guard let filter else { return contacts }

        var result = contacts
        if let isFav = filter.isFavorite {
            result = result.filter { $0.isFavorite == isFav }
        }
        if let source = filter.source {
            result = result.filter { $0.source == source }
        }
        if let query = filter.searchQuery, !query.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        return result
    }

    func search(query: String) async throws -> [Contact] {
        contacts.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func save(_ contact: Contact) async throws {
        if shouldThrow { throw CartioError.unknown("mock error") }
        if let idx = contacts.firstIndex(where: { $0.id == contact.id }) {
            contacts[idx] = contact
        } else {
            contacts.append(contact)
        }
    }

    func delete(_ contact: Contact) async throws {
        if shouldThrow { throw CartioError.unknown("mock error") }
        contacts.removeAll(where: { $0.id == contact.id })
    }

    func findDuplicates(for contact: Contact) async throws -> [Contact] {
        duplicates
    }

    // MARK: - Tags

    var tags: [ContactTag] = []

    func fetchTags() async throws -> [ContactTag] {
        if shouldThrow { throw CartioError.unknown("mock error") }
        return tags
    }

    func createTag(name: String, colorHex: String) async throws -> ContactTag {
        if shouldThrow { throw CartioError.unknown("mock error") }
        let tag = ContactTag(name: name, colorHex: colorHex)
        tags.append(tag)
        return tag
    }

    func deleteTag(_ tag: ContactTag) async throws {
        if shouldThrow { throw CartioError.unknown("mock error") }
        tags.removeAll(where: { $0.id == tag.id })
    }
}
