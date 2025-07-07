import SwiftUI
import PencilKit

struct ContentView: View {
    @StateObject private var wordProvider = WordProvider()
    @StateObject private var sampleTracker = SampleTracker()
    @State private var drawings: [PKDrawing] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var rareLetterProgress: String {
        let rareLetters = "QXZJVKWY"
        let counts = rareLetters.compactMap { letter in
            let count = sampleTracker.letterCounts[letter, default: 0]
            return "\(letter):\(count)"
        }
        return counts.joined(separator: " ")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Pencil Letters")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Total samples: \(sampleTracker.totalSamples())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Rare: \(rareLetterProgress)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button("Stats") {
                    showStatsAlert()
                }
                .font(.headline)
            }
            .padding(.horizontal)
            
            Spacer()
            
            if !drawings.isEmpty {
                WordGridView(word: wordProvider.currentWord, drawings: $drawings)
            }
            
            Spacer()
            
            HStack(spacing: 40) {
                Button(action: clearAll) {
                    Label("Clear", systemImage: "trash")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                
                Button(action: saveAndNext) {
                    Label("Save & Next", systemImage: "checkmark.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .padding()
        .alert("Pencil Letters", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            setupDrawings()
            wordProvider.setSampleTracker(sampleTracker)
        }
    }
    
    private func setupDrawings() {
        drawings = Array(repeating: PKDrawing(), count: wordProvider.currentWord.count)
    }
    
    private func clearAll() {
        for i in 0..<drawings.count {
            drawings[i] = PKDrawing()
        }
    }
    
    private func saveAndNext() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        var savedCount = 0
        
        for (index, drawing) in drawings.enumerated() {
            if drawing.bounds.isEmpty {
                continue
            }
            
            let letter = wordProvider.currentWord[wordProvider.currentWord.index(wordProvider.currentWord.startIndex, offsetBy: index)]
            let letterString = String(letter)
            let letterURL = documentsURL.appendingPathComponent(letterString)
            
            do {
                try FileManager.default.createDirectory(at: letterURL, withIntermediateDirectories: true)
                
                let fileNumber = sampleTracker.getNextFileNumber(for: letter)
                let filename = String(format: "%@_%04d.png", letterString, fileNumber)
                let fileURL = letterURL.appendingPathComponent(filename)
                
                let renderer = ImageRenderer(drawing: drawing, size: CGSize(width: 224, height: 224))
                if let image = renderer.render(),
                   let grayscaleImage = image.toGrayscale(),
                   let pngData = grayscaleImage.pngData() {
                    
                    try pngData.write(to: fileURL)
                    sampleTracker.incrementCount(for: letter)
                    savedCount += 1
                }
            } catch {
                print("Error saving \(letterString): \(error)")
            }
        }
        
        if savedCount > 0 {
            if sampleTracker.isComplete() {
                alertMessage = "🎉 All done! You've collected 100 samples for each letter."
                showingAlert = true
            }
            
            wordProvider.selectNextWord()
            setupDrawings()
        } else {
            alertMessage = "Please write at least one letter before saving."
            showingAlert = true
        }
    }
    
    private func showStatsAlert() {
        var statsText = "Letter counts:\n\n"
        let sortedLetters = sampleTracker.letterCounts.sorted { $0.key < $1.key }
        
        // Group letters by status
        var rareLetters: [(Character, Int)] = []
        var commonLetters: [(Character, Int)] = []
        
        for (letter, count) in sortedLetters {
            if "QXZJVKWY".contains(letter) {
                rareLetters.append((letter, count))
            } else {
                commonLetters.append((letter, count))
            }
        }
        
        // Show rare letters first
        statsText += "Rare Letters:\n"
        for (letter, count) in rareLetters {
            let checkmark = count >= 100 ? "✓" : ""
            let emphasis = count < 100 ? "⚠️" : ""
            statsText += "\(letter): \(count)/100 \(checkmark)\(emphasis)\n"
        }
        
        statsText += "\nCommon Letters:\n"
        for (letter, count) in commonLetters {
            let checkmark = count >= 100 ? "✓" : ""
            statsText += "\(letter): \(count)/100 \(checkmark)\n"
        }
        
        alertMessage = statsText
        showingAlert = true
    }
}