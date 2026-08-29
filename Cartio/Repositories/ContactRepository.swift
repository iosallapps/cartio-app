//
//  ContactRepository.swift
//  Cartio
//

import Foundation
import SwiftData

final class ContactRepository: ContactRepositoryProtocol {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchAll(filter: ContactFilter?) async throws -> [Contact] {
        guard let filter else {
            let descriptor = FetchDescriptor<Contact>(sortBy: [SortDescriptor(\.name)])
            return try modelContext.fetch(descriptor)
        }

        let isFavoriteFilter = filter.isFavorite
        let searchQuery = filter.searchQuery
        let tagIDs = filter.tagIDs
        let sourceFilter = filter.source?.rawValue

        let descriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { contact in
                (isFavoriteFilter == nil || contact.isFavorite == isFavoriteFilter!)
                && (searchQuery == nil || contact.name.localizedStandardContains(searchQuery!))
                && (sourceFilter == nil || contact.source.rawValue == sourceFilter!)
            },
            sortBy: [SortDescriptor(\.name)]
        )

        var results = try modelContext.fetch(descriptor)

        // Filter by tagIDs in-memory since SwiftData #Predicate doesn't support
        // contains() on relationship collections easily
        if let tagIDs, !tagIDs.isEmpty {
            results = results.filter { contact in
                contact.tags.contains { tagIDs.contains($0.id) }
            }
        }

        return results
    }

    func search(query: String) async throws -> [Contact] {
        let descriptor = FetchDescriptor<Contact>(
            predicate: #Predicate { contact in
                contact.name.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    func save(_ contact: Contact) async throws {
        contact.updatedAt = .now
        modelContext.insert(contact)
        try modelContext.save()
    }

    func saveAll(_ contacts: [Contact]) async throws {
        for contact in contacts {
            contact.updatedAt = .now
            modelContext.insert(contact)
        }
        try modelContext.save()
    }

    func delete(_ contact: Contact) async throws {
        // Collect tags that may become orphaned after deletion
        let tagsToCheck = contact.tags

        modelContext.delete(contact)
        try modelContext.save()

        // Clean up orphaned tags (tags with no remaining contacts)
        for tag in tagsToCheck where tag.contacts.isEmpty {
            modelContext.delete(tag)
        }
        try modelContext.save()
    }

    func findDuplicates(for contact: Contact) async throws -> [Contact] {
        guard !contact.name.isEmpty else { return [] }
        let name = contact.name
        let descriptor = FetchDescriptor<Contact>(
            predicate: #Predicate { $0.name == name }
        )
        return try modelContext.fetch(descriptor).filter { $0.id != contact.id }
    }

    // MARK: - Tags

    func fetchTags() async throws -> [ContactTag] {
        let descriptor = FetchDescriptor<ContactTag>(sortBy: [SortDescriptor(\.name)])
        return try modelContext.fetch(descriptor)
    }

    func createTag(name: String, colorHex: String) async throws -> ContactTag {
        let tag = ContactTag(name: name, colorHex: colorHex)
        modelContext.insert(tag)
        try modelContext.save()
        return tag
    }

    func deleteTag(_ tag: ContactTag) async throws {
        modelContext.delete(tag)
        try modelContext.save()
    }
}
