import Foundation

class WordProvider: ObservableObject {
    @Published var currentWord: String = ""
    private var sampleTracker: SampleTracker?
    
    // Words grouped by rare letters they contain
    private let rareLetterWords: [Character: [String]] = [
        "Q": ["QUEEN", "QUIET", "QUICK", "QUAKE", "QUEST", "QUOTE", "QUIRK", "QUILT", "SQUAD", "EQUAL"],
        "X": ["XEROX", "EXTRA", "MIXED", "PIXEL", "TOXIC", "BOXER", "EXACT", "OXIDE", "RELAX", "NEXUS"],
        "Z": ["ZEBRA", "ZONES", "CRAZY", "FROZE", "PIZZA", "PRIZE", "BLAZE", "FUZZY", "HAZEL", "RAZOR"],
        "J": ["JOKER", "JUDGE", "JELLY", "JUICE", "MAJOR", "ENJOY", "JENGA", "JUMBO", "JOINT", "JETTY"],
        "V": ["VOICE", "VIVID", "RIVER", "ABOVE", "HEAVY", "VALVE", "VENOM", "COVER", "GROVE", "BRAVE"],
        "K": ["KNIFE", "KITTY", "KAYAK", "KIOSK", "KNOCK", "ANKLE", "BRAKE", "CHALK", "FLASK", "SPARK"],
        "W": ["WATER", "WORLD", "WRIST", "SWEET", "TOWER", "CROWN", "LOWER", "POWER", "SWIFT", "WHEAT"],
        "Y": ["YOUTH", "YOUNG", "YELLOW", "YEAST", "EARLY", "HAPPY", "SHINY", "EMPTY", "STYLE", "PARTY"]
    ]
    
    // Common words for when rare letters are well-represented
    private let commonWords = [
        "APPLE", "BREAD", "CHAIR", "DANCE", "EAGLE",
        "FRESH", "GRAPE", "HOUSE", "LIGHT", "MOUSE",
        "NIGHT", "OCEAN", "PIANO", "RADIO", "STONE",
        "TIGER", "UNDER", "BEACH", "CLOCK", "DREAM",
        "FLAME", "GHOST", "HEART", "IMAGE", "LASER",
        "MAGIC", "NORTH", "ORBIT", "PEARL", "SPORT",
        "TRUCK", "ABOUT", "BROWN", "DRIVE", "EIGHT",
        // Words rich in F, M, B, D, P, G, H
        "FAMILY", "FIELD", "FOUND", "FIFTY", "FABLE",
        "MEMBER", "MIGHT", "MONTH", "METAL", "MARCH",
        "BADGE", "BLOCK", "BOARD", "BELOW", "BENCH",
        "DEPTH", "DOUBT", "DRAFT", "DAILY", "MEDAL",
        "PHASE", "PLUMB", "PRIDE", "PROOF", "PUPIL",
        "GLOBE", "GUARD", "GAUGE", "GRIND", "GRAND",
        "HUMOR", "HOTEL", "HONEY", "HEDGE", "HABIT"
    ]
    
    init() {
        selectNextWord()
    }
    
    func setSampleTracker(_ tracker: SampleTracker) {
        self.sampleTracker = tracker
    }
    
    func selectNextWord() {
        guard let tracker = sampleTracker else {
            currentWord = commonWords.randomElement() ?? "HELLO"
            return
        }
        
        // Find ALL letters that need more samples
        let targetCount = 100
        var underrepresentedLetters: [(Character, Int)] = []
        
        for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            let count = tracker.letterCounts[letter, default: 0]
            if count < targetCount {
                underrepresentedLetters.append((letter, targetCount - count))
            }
        }
        
        // Sort by most needed first
        underrepresentedLetters.sort { $0.1 > $1.1 }
        
        // If we have underrepresented letters, find words containing them
        if !underrepresentedLetters.isEmpty {
            // Get the top 3 most needed letters
            let topNeeded = underrepresentedLetters.prefix(3).map { $0.0 }
            
            // Find words containing these letters
            var candidateWords: [String] = []
            let allWords = commonWords + rareLetterWords.values.flatMap { $0 }
            
            for word in allWords {
                for letter in topNeeded {
                    if word.contains(letter) {
                        candidateWords.append(word)
                        break
                    }
                }
            }
            
            // Prioritize words with multiple needed letters
            let scoredWords = candidateWords.map { word -> (String, Int) in
                let score = topNeeded.reduce(0) { count, letter in
                    count + (word.contains(letter) ? 1 : 0)
                }
                return (word, score)
            }
            
            let bestWords = scoredWords.filter { $0.1 == scoredWords.map { $0.1 }.max() }
            if let selected = bestWords.randomElement() {
                currentWord = selected.0
                return
            }
        }
        
        // Otherwise pick from all words
        let allWords = commonWords + rareLetterWords.values.flatMap { $0 }
        currentWord = allWords.randomElement() ?? "HELLO"
    }
}