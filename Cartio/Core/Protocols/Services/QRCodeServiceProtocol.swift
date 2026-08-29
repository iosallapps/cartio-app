//
//  QRCodeServiceProtocol.swift
//  Cartio
//

import UIKit

@MainActor
protocol QRCodeServiceProtocol {
    func generate(from string: String, size: CGSize, foregroundColor: UIColor) -> UIImage?
}
