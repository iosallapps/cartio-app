//
//  FirestoreService.swift
//  Cartio
//

import Foundation

final class FirestoreService {

    // TODO: Add Firebase import and implement when SPM dependency is added

    func save<T: Codable>(_ document: T, collection: String, documentID: String) async throws {
        // TODO: Firestore setData
    }

    func fetch<T: Codable>(collection: String, documentID: String, as type: T.Type) async throws -> T? {
        // TODO: Firestore getDocument
        return nil
    }

    func fetchAll<T: Codable>(collection: String, as type: T.Type) async throws -> [T] {
        // TODO: Firestore getDocuments
        return []
    }

    func delete(collection: String, documentID: String) async throws {
        // TODO: Firestore deleteDocument
    }
}
