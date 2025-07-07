import Foundation

class SampleTracker: ObservableObject {
    @Published var letterCounts: [Character: Int] = [:]
    private let documentsURL: URL
    
    init() {
        self.documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        loadCounts()
    }
    
    func loadCounts() {
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            let letterURL = documentsURL.appendingPathComponent(String(letter))
            
            if FileManager.default.fileExists(atPath: letterURL.path) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(at: letterURL, includingPropertiesForKeys: nil)
                    let pngFiles = files.filter { $0.pathExtension == "png" }
                    letterCounts[letter] = pngFiles.count
                } catch {
                    letterCounts[letter] = 0
                }
            } else {
                letterCounts[letter] = 0
            }
        }
    }
    
    func incrementCount(for letter: Character) {
        letterCounts[letter, default: 0] += 1
    }
    
    func getNextFileNumber(for letter: Character) -> Int {
        return letterCounts[letter, default: 0] + 1
    }
    
    func totalSamples() -> Int {
        return letterCounts.values.reduce(0, +)
    }
    
    func isComplete() -> Bool {
        return letterCounts.allSatisfy { $0.value >= 100 }
    }
}