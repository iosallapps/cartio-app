//
//  ContactInteractorTests.swift
//  CartioTests
//

import Testing
import Foundation
@testable import Cartio

@MainActor
struct ContactInteractorTests {

    // MARK: - Helpers

    private func makeSUT(
        contacts: [Contact] = [],
        grantAccess: Bool = true
    ) -> (ContactInteractor, MockContactRepository, MockAppleContactsService) {
        let repo = MockContactRepository()
        repo.contacts = contacts
        let service = MockAppleContactsService()
        service.grantAccess = grantAccess
        let interactor = ContactInteractor(repository: repo, appleContactsService: service)
        return (interactor, repo, service)
    }

    private func makeContact(name: String = "Test", source: ContactSource = .manual) -> Contact {
        Contact(name: name, source: source)
    }

    // MARK: - Fetch

    @Test func fetchContacts_returnsAll() async throws {
        let contacts = [makeContact(name: "A"), makeContact(name: "B")]
        let (sut, _, _) = makeSUT(contacts: contacts)

        let result = try await sut.fetchContacts(filter: nil)
        #expect(result.count == 2)
    }

    @Test func fetchContacts_withFavoriteFilter() async throws {
        let fav = makeContact(name: "Fav")
        fav.isFavorite = true
        let normal = makeContact(name: "Normal")
        let (sut, _, _) = makeSUT(contacts: [fav, normal])

        let result = try await sut.fetchContacts(filter: ContactFilter(isFavorite: true))
        #expect(result.count == 1)
        #expect(result.first?.name == "Fav")
    }

    @Test func fetchContacts_withSourceFilter() async throws {
        let scanned = makeContact(name: "Scanned", source: .scanned)
        let manual = makeContact(name: "Manual", source: .manual)
        let (sut, _, _) = makeSUT(contacts: [scanned, manual])

        let result = try await sut.fetchContacts(filter: ContactFilter(source: .scanned))
        #expect(result.count == 1)
        #expect(result.first?.name == "Scanned")
    }

    // MARK: - Search

    @Test func searchContacts_findsMatchingNames() async throws {
        let contacts = [makeContact(name: "Alice"), makeContact(name: "Bob")]
        let (sut, _, _) = makeSUT(contacts: contacts)

        let result = try await sut.searchContacts(query: "Ali")
        #expect(result.count == 1)
        #expect(result.first?.name == "Alice")
    }

    // MARK: - Save & Delete

    @Test func saveContact_addsToRepository() async throws {
        let (sut, repo, _) = makeSUT()
        let contact = makeContact(name: "New")

        try await sut.saveContact(contact)
        #expect(repo.contacts.count == 1)
    }

    @Test func deleteContact_removesFromRepository() async throws {
        let contact = makeContact(name: "ToDelete")
        let (sut, repo, _) = makeSUT(contacts: [contact])

        try await sut.deleteContact(contact)
        #expect(repo.contacts.isEmpty)
    }

    // MARK: - Duplicate Detection

    @Test func detectDuplicates_returnsDuplicates() async throws {
        let existing = makeContact(name: "John")
        let (sut, repo, _) = makeSUT()
        repo.duplicates = [existing]

        let newContact = makeContact(name: "John")
        let result = try await sut.detectDuplicates(for: newContact)
        #expect(result.count == 1)
    }

    // MARK: - Apple Contacts Import

    @Test func importFromAppleContacts_succeeds() async throws {
        let imported = [makeContact(name: "Imported", source: .imported)]
        let (sut, _, service) = makeSUT()
        service.contactsToReturn = imported

        let result = try await sut.importFromAppleContacts()
        #expect(result.count == 1)
        #expect(result.first?.name == "Imported")
    }

    @Test func importFromAppleContacts_throwsWhenDenied() async throws {
        let (sut, _, _) = makeSUT(grantAccess: false)

        await #expect(throws: CartioError.self) {
            _ = try await sut.importFromAppleContacts()
        }
    }
}
