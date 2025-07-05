import SwiftUI
import PencilKit

/// A UIViewRepresentable wrapper for PKCanvasView to use PencilKit in SwiftUI
struct PencilKitView: UIViewRepresentable {
    /// Binding to the current drawing
    @Binding var drawing: PKDrawing
    
    /// Whether the canvas should allow drawing
    var isDrawingEnabled: Bool = true
    
    /// The coordinator handles delegation and interaction
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilKitView
        
        init(_ parent: PencilKitView) {
            self.parent = parent
        }
        
        /// Called when the drawing changes
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            // Dispatch the update to avoid modifying state during view update
            DispatchQueue.main.async {
                self.parent.drawing = canvasView.drawing
            }
        }
    }
    
    /// Create the coordinator for handling delegation
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// Create and configure the PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        
        // Configure the canvas view
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing
        canvasView.alwaysBounceVertical = false
        canvasView.allowsFingerDrawing = false // Apple Pencil only
        canvasView.isOpaque = false
        canvasView.backgroundColor = .systemGray6
        
        // Set up the tool picker with a thicker default pen
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let toolPicker = PKToolPicker()
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                toolPicker.addObserver(canvasView)
                
                // Set a thicker black pen as the default tool
                let thickPen = PKInkingTool(.pen, color: .black, width: 20)
                canvasView.tool = thickPen
                
                canvasView.becomeFirstResponder()
            }
        }
        
        return canvasView
    }
    
    /// Update the canvas view when SwiftUI state changes
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Update drawing if it changed externally
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
        
        // Update drawing enabled state
        uiView.isUserInteractionEnabled = isDrawingEnabled
    }
}