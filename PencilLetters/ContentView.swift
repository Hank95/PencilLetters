//
//  ContentView.swift
//  PencilLetters
//
//  Created by Henry Pendleton on 7/5/25.
//

import SwiftUI
import PencilKit

struct ContentView: View {
    /// Current letter being practiced (A-Z)
    @State private var currentLetter: Character = "A"
    
    /// The current drawing
    @State private var drawing = PKDrawing()
    
    /// Alert states
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    /// Sample counts for each letter
    @State private var sampleCounts: [Character: Int] = [:]
    
    /// Track available letters (those with < 100 samples)
    @State private var availableLetters: Set<Character> = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    /// Maximum samples per letter
    private let maxSamplesPerLetter = 100
    
    /// Get sample count for current letter
    private var currentLetterSampleCount: Int {
        sampleCounts[currentLetter] ?? 0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with current letter and sample count
            VStack(spacing: 10) {
                Text("Draw the letter: \(String(currentLetter))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                // Sample counter
                Text("Samples collected: \(currentLetterSampleCount) / \(maxSamplesPerLetter)")
                    .font(.title2)
                    .foregroundColor(currentLetterSampleCount >= maxSamplesPerLetter ? .green : .primary)
            }
            .padding(.top, 40)
            
            // Drawing canvas with grid overlay
            ZStack {
                // White background
                Color.white
                
                // Grid overlay to simulate crossword cell
                GeometryReader { geometry in
                    Path { path in
                        let cellSize = geometry.size.width
                        let gridSpacing = cellSize / 3
                        
                        // Vertical lines
                        for i in 1...2 {
                            let x = CGFloat(i) * gridSpacing
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: cellSize))
                        }
                        
                        // Horizontal lines
                        for i in 1...2 {
                            let y = CGFloat(i) * gridSpacing
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: cellSize, y: y))
                        }
                    }
                    .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                
                // PencilKit drawing view
                PencilKitView(drawing: $drawing)
            }
            .frame(width: 600, height: 600)
            .cornerRadius(20)
            .shadow(radius: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
            )
            .padding()
            
            // Control buttons
            HStack(spacing: 30) {
                // Clear button
                Button(action: clearCanvas) {
                    Label("Clear", systemImage: "trash")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.red)
                
                // Save button - single tap workflow
                Button(action: saveAndAdvance) {
                    Label("Save & Next", systemImage: "checkmark.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                .disabled(currentLetterSampleCount >= maxSamplesPerLetter)
            }
            .padding(.bottom, 40)
            
            // Progress overview
            if !availableLetters.isEmpty {
                Text("Letters remaining: \(availableLetters.count) / 26")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("All letters completed! 🎉")
                    .font(.title3)
                    .foregroundColor(.green)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .alert("Save Result", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            loadSampleCounts()
        }
    }
    
    /// Clear the drawing canvas
    private func clearCanvas() {
        drawing = PKDrawing()
    }
    
    /// Save sample and automatically advance to next letter
    private func saveAndAdvance() {
        // Check if drawing is empty
        guard !drawing.strokes.isEmpty else {
            alertMessage = "Please draw something before saving!"
            showingAlert = true
            return
        }
        
        // Save the sample
        if saveSample() {
            // Update sample count
            sampleCounts[currentLetter] = (sampleCounts[currentLetter] ?? 0) + 1
            
            // Check if this letter has reached max samples
            if sampleCounts[currentLetter] ?? 0 >= maxSamplesPerLetter {
                availableLetters.remove(currentLetter)
            }
            
            // Clear canvas
            clearCanvas()
            
            // Select next random letter
            selectRandomLetter()
        }
    }
    
    /// Save the current drawing as a grayscale PNG
    private func saveSample() -> Bool {
        // Render the drawing to an image
        let renderer = ImageRenderer(drawing: drawing, size: CGSize(width: 224, height: 224))
        
        guard let image = renderer.render() else {
            alertMessage = "Failed to render drawing"
            showingAlert = true
            return false
        }
        
        // Convert to grayscale
        guard let grayscaleImage = image.toGrayscale() else {
            alertMessage = "Failed to convert to grayscale"
            showingAlert = true
            return false
        }
        
        // Save the image
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let letterFolder = documentsURL.appendingPathComponent(String(currentLetter))
        
        do {
            // Create letter folder if it doesn't exist
            try fileManager.createDirectory(at: letterFolder, withIntermediateDirectories: true)
            
            // Find the next available file number
            let existingFiles = try fileManager.contentsOfDirectory(at: letterFolder, includingPropertiesForKeys: nil)
            let imageFiles = existingFiles.filter { $0.pathExtension == "png" }
            let nextNumber = imageFiles.count + 1
            
            // Create filename
            let filename = String(format: "%@_%04d.png", String(currentLetter), nextNumber)
            let fileURL = letterFolder.appendingPathComponent(filename)
            
            // Save the image
            if let data = grayscaleImage.pngData() {
                try data.write(to: fileURL)
                
                // Print the full path for debugging
                print("Saved image to: \(fileURL.path)")
                
                return true
            } else {
                throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG data"])
            }
            
        } catch {
            alertMessage = "Error saving: \(error.localizedDescription)"
            showingAlert = true
            return false
        }
    }
    
    /// Select a random letter from available letters (excluding current)
    private func selectRandomLetter() {
        // If no letters available, we're done
        guard !availableLetters.isEmpty else {
            alertMessage = "All letters completed! Great job! 🎉"
            showingAlert = true
            return
        }
        
        // Get available letters excluding current one
        var candidateLetters = availableLetters
        if candidateLetters.count > 1 {
            candidateLetters.remove(currentLetter)
        }
        
        // Select random letter
        if let randomLetter = candidateLetters.randomElement() {
            currentLetter = randomLetter
        }
    }
    
    /// Load sample counts from disk
    private func loadSampleCounts() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Reset counts and available letters
        sampleCounts = [:]
        availableLetters = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        
        // Count samples for each letter
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            let letterFolder = documentsURL.appendingPathComponent(String(letter))
            
            if let files = try? fileManager.contentsOfDirectory(at: letterFolder, includingPropertiesForKeys: nil) {
                let pngCount = files.filter { $0.pathExtension == "png" }.count
                if pngCount > 0 {
                    sampleCounts[letter] = pngCount
                    
                    // Remove from available if already has max samples
                    if pngCount >= maxSamplesPerLetter {
                        availableLetters.remove(letter)
                    }
                }
            }
        }
        
        // Select initial random letter from available ones
        selectRandomLetter()
    }
}

#Preview {
    ContentView()
}