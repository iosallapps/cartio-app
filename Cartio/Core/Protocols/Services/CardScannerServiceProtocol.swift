//
//  CardScannerServiceProtocol.swift
//  Cartio
//

import UIKit

struct ScannedCardData {
    var name: String?
    var title: String?
    var company: String?
    var email: String?
    var phone: String?
    var website: String?
    var originalImage: UIImage?
}

@MainActor
protocol CardScannerServiceProtocol {
    func scanImage(_ image: UIImage) async throws -> ScannedCardData
}
