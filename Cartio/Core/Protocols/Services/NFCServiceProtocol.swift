//
//  NFCServiceProtocol.swift
//  Cartio
//

import Foundation

@MainActor
protocol NFCServiceProtocol {
    var isAvailable: Bool { get }
    func readTag() async throws -> String
    func writeTag(url: String) async throws
}
