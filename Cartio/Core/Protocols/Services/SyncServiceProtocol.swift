//
//  SyncServiceProtocol.swift
//  Cartio
//

import Foundation
import Combine

@MainActor
protocol SyncServiceProtocol {
    var isOnline: Bool { get }
    var isOnlinePublisher: AnyPublisher<Bool, Never> { get }

    func processQueue() async throws
    func startMonitoring()
    func stopMonitoring()
}
