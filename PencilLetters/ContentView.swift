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
    @State private var currentLetterIndex = 0
    
    /// The current drawing
    @State private var drawing = PKDrawing()
    
    /// Alert states
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    /// Array of letters A-Z
    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    
    /// Get the current letter
    private var currentLetter: String {
        String(letters[currentLetterIndex])
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with current letter
            Text("Draw the letter: \(currentLetter)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
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
                // Previous letter button
                Button(action: previousLetter) {
                    Label("Previous", systemImage: "chevron.left")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(currentLetterIndex == 0)
                
                // Clear button
                Button(action: clearCanvas) {
                    Label("Clear", systemImage: "trash")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.red)
                
                // Save button
                Button(action: saveSample) {
                    Label("Save Sample", systemImage: "square.and.arrow.down")
                        .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.green)
                
                // Next letter button
                Button(action: nextLetter) {
                    Label("Next", systemImage: "chevron.right")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(currentLetterIndex == letters.count - 1)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .alert("Save Result", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    /// Move to the previous letter
    private func previousLetter() {
        if currentLetterIndex > 0 {
            currentLetterIndex -= 1
            clearCanvas()
        }
    }
    
    /// Move to the next letter
    private func nextLetter() {
        if currentLetterIndex < letters.count - 1 {
            currentLetterIndex += 1
            clearCanvas()
        }
    }
    
    /// Clear the drawing canvas
    private func clearCanvas() {
        drawing = PKDrawing()
    }
    
    /// Save the current drawing as a grayscale PNG
    private func saveSample() {
        // Check if drawing is empty
        guard !drawing.strokes.isEmpty else {
            alertMessage = "Please draw something before saving!"
            showingAlert = true
            return
        }
        
        // Render the drawing to an image
        let renderer = ImageRenderer(drawing: drawing, size: CGSize(width: 224, height: 224))
        
        guard let image = renderer.render() else {
            alertMessage = "Failed to render drawing"
            showingAlert = true
            return
        }
        
        // Convert to grayscale
        guard let grayscaleImage = image.toGrayscale() else {
            alertMessage = "Failed to convert to grayscale"
            showingAlert = true
            return
        }
        
        // Save the image
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let letterFolder = documentsURL.appendingPathComponent(currentLetter)
        
        do {
            // Create letter folder if it doesn't exist
            try fileManager.createDirectory(at: letterFolder, withIntermediateDirectories: true)
            
            // Find the next available file number
            let existingFiles = try fileManager.contentsOfDirectory(at: letterFolder, includingPropertiesForKeys: nil)
            let imageFiles = existingFiles.filter { $0.pathExtension == "png" }
            let nextNumber = imageFiles.count + 1
            
            // Create filename
            let filename = String(format: "%@_%04d.png", currentLetter, nextNumber)
            let fileURL = letterFolder.appendingPathComponent(filename)
            
            // Save the image
            if let data = grayscaleImage.pngData() {
                try data.write(to: fileURL)
                
                // Print the full path for debugging
                print("Saved image to: \(fileURL.path)")
                
                alertMessage = "Saved as \(filename)\nPath: \(letterFolder.path)"
                showingAlert = true
                
                // Clear the canvas after successful save
                clearCanvas()
            } else {
                throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG data"])
            }
            
        } catch {
            alertMessage = "Error saving: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

#Preview {
    ContentView()
}