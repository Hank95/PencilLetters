import SwiftUI
import PencilKit

struct WordGridView: View {
    let word: String
    let cellSize: CGFloat = 80
    @Binding var drawings: [PKDrawing]
    
    init(word: String, drawings: Binding<[PKDrawing]>) {
        self.word = word
        self._drawings = drawings
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Write: \(word)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 8) {
                ForEach(0..<word.count, id: \.self) { index in
                    VStack(spacing: 4) {
                        LetterCell(
                            cellSize: cellSize,
                            drawing: $drawings[index]
                        )
                        .frame(width: cellSize, height: cellSize)
                        
                        Text(String(word[word.index(word.startIndex, offsetBy: index)]))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
    }
    
    func clearAll() {
        for i in 0..<drawings.count {
            drawings[i] = PKDrawing()
        }
    }
}