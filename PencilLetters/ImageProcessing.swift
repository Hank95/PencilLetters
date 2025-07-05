import UIKit
import PencilKit

/// Image renderer for PKDrawing that handles sizing and rendering
struct ImageRenderer {
    let drawing: PKDrawing
    let size: CGSize
    
    /// Render the PKDrawing to a UIImage at the specified size
    func render() -> UIImage? {
        // Use the canvas size (600x600) as the source size
        let canvasSize = CGSize(width: 600, height: 600)
        
        // Create an image from the entire canvas area
        let image = drawing.image(from: CGRect(origin: .zero, size: canvasSize), scale: 1.0)
        
        // Create a new context at the target size (224x224)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        // Fill with white background
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        // Draw the image scaled down to fit the target size
        image.draw(in: CGRect(origin: .zero, size: size))
        
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