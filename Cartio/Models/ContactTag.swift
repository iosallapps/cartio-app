//
//  ContactTag.swift
//  Cartio
//

import Foundation
import SwiftData

@Model
final class ContactTag {

    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String

    @Relationship(deleteRule: .nullify, inverse: \Contact.tags)
    var contacts: [Contact]

    init(
        id: UUID = UUID(),
        name: String = "",
        colorHex: String = "#0A7E8C"
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.contacts = []
    }
}
