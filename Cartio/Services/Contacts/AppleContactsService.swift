//
//  AppleContactsService.swift
//  Cartio
//

import Foundation
import Contacts

final class AppleContactsService: AppleContactsServiceProtocol {

    private let store = CNContactStore()

    func requestAccess() async throws -> Bool {
        try await store.requestAccess(for: .contacts)
    }

    func fetchContacts() async throws -> [Contact] {
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactJobTitleKey as CNKeyDescriptor,
            CNContactOrganizationNameKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        var contacts: [Contact] = []

        try store.enumerateContacts(with: request) { cnContact, _ in
            let name = [cnContact.givenName, cnContact.familyName]
                .filter { !$0.isEmpty }
                .joined(separator: " ")

            let contact = Contact(
                name: name,
                title: cnContact.jobTitle.isEmpty ? nil : cnContact.jobTitle,
                company: cnContact.organizationName.isEmpty ? nil : cnContact.organizationName,
                email: cnContact.emailAddresses.first?.value as String?,
                phone: cnContact.phoneNumbers.first?.value.stringValue,
                source: .imported
            )
            contacts.append(contact)
        }

        return contacts
    }

    func saveContact(from card: BusinessCard) async throws {
        let contact = CNMutableContact()
        let nameParts = card.name.components(separatedBy: " ")
        contact.givenName = nameParts.first ?? ""
        contact.familyName = nameParts.dropFirst().joined(separator: " ")
        contact.jobTitle = card.title
        contact.organizationName = card.company

        if !card.email.isEmpty {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: card.email as NSString)]
        }
        if !card.phone.isEmpty {
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: card.phone))]
        }

        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)
        try store.execute(saveRequest)
    }
}
