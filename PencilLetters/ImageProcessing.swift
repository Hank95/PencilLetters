import UIKit
import PencilKit

/// Image renderer for PKDrawing that handles sizing and rendering
struct ImageRenderer {
    let drawing: PKDrawing
    let size: CGSize
    
    /// Render the PKDrawing to a UIImage at the specified size
    func render() -> UIImage? {
        // Get the actual bounds of the drawing content
        let bounds = drawing.bounds
        
        // If drawing is empty, return nil
        if bounds.isEmpty {
            return nil
        }
        
        // Add padding around the drawing
        let padding: CGFloat = 20
        let paddedBounds = bounds.insetBy(dx: -padding, dy: -padding)
        
        // Create an image from just the drawn content area (not the entire canvas)
        let image = drawing.image(from: paddedBounds, scale: 3.0)
        
        // Create a new context at the target size (224x224)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // Fill with white background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Calculate aspect fit rectangle to maintain aspect ratio
        let imageSize = image.size
        let widthRatio = size.width / imageSize.width
        let heightRatio = size.height / imageSize.height
        let scale = min(widthRatio, heightRatio) * 0.9 // 90% to leave some margin
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let x = (size.width - scaledWidth) / 2
        let y = (size.height - scaledHeight) / 2
        
        // Draw the image centered and scaled to fit
        image.draw(in: CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight))
        
        // Get the rendered image
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension UIImage {
    /// Convert the image to grayscale
    func toGrayscale() -> UIImage? {
        // Create a grayscale context
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = Int(size.width)
        let height = Int(size.height)
        
        // Create bitmap context
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else {
            return nil
        }
        
        // Draw the image in the grayscale context
        guard let cgImage = self.cgImage else { return nil }
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.draw(cgImage, in: rect)
        
        // Create new image from grayscale context
        guard let grayscaleCGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: grayscaleCGImage)
    }
}