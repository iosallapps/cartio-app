//
//  CartioSchema.swift
//  Cartio
//
//  SwiftData versioned schema — prevents migration nightmares.
//

import SwiftData

enum CartioSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BusinessCard.self,
            Contact.self,
            ContactTag.self,
            UserProfile.self,
            ShareRecord.self
        ]
    }
}

enum CartioSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            BusinessCard.self,
            Contact.self,
            ContactTag.self,
            UserProfile.self,
            ShareRecord.self,
            CardEvent.self
        ]
    }
}

enum CartioMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CartioSchemaV1.self, CartioSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: CartioSchemaV1.self,
        toVersion: CartioSchemaV2.self
    )
}
