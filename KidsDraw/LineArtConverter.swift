import UIKit
import CoreImage

enum LineArtConverter {
    private static let ciContext = CIContext(options: [.useSoftwareRenderer: false])

    static func convertToLineArt(image: UIImage) -> UIImage? {
        // 1. Resize image to optimal processing size to keep line weight crisp
        let maxDimension: CGFloat = 1024
        let size = image.size
        let ratio = min(maxDimension / max(size.width, size.height), 1.0)
        let targetSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: rendererFormat)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        guard let ciInput = CIImage(image: resizedImage) else { return nil }

        // 2. CILineOverlay: generates high-contrast sketch outlines (black on white)
        guard let lineFilter = CIFilter(name: "CILineOverlay") else { return nil }
        lineFilter.setValue(ciInput, forKey: kCIInputImageKey)
        lineFilter.setValue(0.06, forKey: "inputNRNoiseLevel")
        lineFilter.setValue(0.68, forKey: "inputNRSharpness")
        lineFilter.setValue(1.0, forKey: "inputEdgeIntensity")
        lineFilter.setValue(0.12, forKey: "inputThreshold")
        lineFilter.setValue(45.0, forKey: "inputContrast")

        guard let lineOutput = lineFilter.outputImage else { return nil }

        // 3. Invert color: lines become white, background becomes black
        guard let invertFilter = CIFilter(name: "CIColorInvert") else { return nil }
        invertFilter.setValue(lineOutput, forKey: kCIInputImageKey)
        guard let inverted = invertFilter.outputImage else { return nil }

        // 4. Convert luminance to alpha: lines remain opaque, background becomes transparent
        guard let maskFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        maskFilter.setValue(inverted, forKey: kCIInputImageKey)
        guard let alphaMask = maskFilter.outputImage else { return nil }

        // 5. Apply clean dark line-art color (#2E2E36)
        guard let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
        colorFilter.setValue(CIColor(red: 0.18, green: 0.18, blue: 0.22), forKey: kCIInputColorKey)
        guard let colorImage = colorFilter.outputImage else { return nil }

        guard let blendFilter = CIFilter(name: "CIBlendWithAlphaMask") else { return nil }
        blendFilter.setValue(colorImage, forKey: kCIInputImageKey)
        blendFilter.setValue(CIImage.empty(), forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(alphaMask, forKey: kCIInputMaskImageKey)
        guard let finalCI = blendFilter.outputImage else { return nil }

        let extent = CGRect(origin: .zero, size: targetSize)
        guard let cgImage = ciContext.createCGImage(finalCI, from: extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
