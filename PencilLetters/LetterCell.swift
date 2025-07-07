import SwiftUI
import PencilKit

struct LetterCell: UIViewRepresentable {
    let cellSize: CGFloat
    @Binding var drawing: PKDrawing
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.backgroundColor = .white
        canvasView.drawingPolicy = .pencilOnly
        canvasView.isOpaque = false
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 20)
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        
        canvasView.layer.borderWidth = 2
        canvasView.layer.borderColor = UIColor.black.cgColor
        canvasView.layer.cornerRadius = 4
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: LetterCell
        
        init(_ parent: LetterCell) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}