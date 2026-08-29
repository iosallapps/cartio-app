//
//  QRCodeService.swift
//  Cartio
//
//  Native CIFilter-based QR generation. No third-party dependency.
//

import UIKit
import CoreImage.CIFilterBuiltins

final class QRCodeService: QRCodeServiceProtocol {

    func generate(from string: String, size: CGSize, foregroundColor: UIColor = .black) -> UIImage? {
        let context = CIContext()

        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        // Apply color
        let colorFilter = CIFilter.falseColor()
        colorFilter.inputImage = outputImage
        colorFilter.color0 = CIColor(color: foregroundColor)
        colorFilter.color1 = CIColor(color: .white)

        guard let coloredImage = colorFilter.outputImage else { return nil }

        // Scale to desired size
        let scaleX = size.width / coloredImage.extent.size.width
        let scaleY = size.height / coloredImage.extent.size.height
        let scale = min(scaleX, scaleY)

        let scaledImage = coloredImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
