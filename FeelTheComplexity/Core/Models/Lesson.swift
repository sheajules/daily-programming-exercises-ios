import Foundation
import SwiftData

@Model
final class Lesson {
    var id: String = UUID().uuidString
    var title: String = ""
    var description: String = ""
    var category: LessonCategory = .loops
    var difficulty: LessonDifficulty = .beginner
    var complexity: BigOComplexity = .linear
    var codeSnippet: String = ""
    var instructions: [String] = []
    var expectedOutput: String = ""
    var hint: String = ""
    var xpReward: Int = 10
    var estimatedTime: Int = 5 // minutes
    var prerequisites: [String] = []
    var isUnlocked: Bool = false
    var isCompleted: Bool = false
    var bestScore: Int = 0
    var attempts: Int = 0
    var createdDate: Date = Date()
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        category: LessonCategory,
        difficulty: LessonDifficulty,
        complexity: BigOComplexity,
        codeSnippet: String,
        instructions: [String],
        expectedOutput: String,
        hint: String = "",
        xpReward: Int = 10,
        estimatedTime: Int = 5,
        prerequisites: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.complexity = complexity
        self.codeSnippet = codeSnippet
        self.instructions = instructions
        self.expectedOutput = expectedOutput
        self.hint = hint
        self.xpReward = xpReward
        self.estimatedTime = estimatedTime
        self.prerequisites = prerequisites
        self.createdDate = Date()
    }
}

enum LessonCategory: String, CaseIterable, Codable {
    case loops = "Linear Thinking"
    case logarithmic = "Logarithmic Intuition"
    case nested = "Nested Growth"
    case scaling = "Scaling Battles"
    case advanced = "Advanced Patterns"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .loops: return "arrow.clockwise"
        case .logarithmic: return "arrow.down.right.and.arrow.up.left"
        case .nested: return "square.stack.3d.up"
        case .scaling: return "speedometer"
        case .advanced: return "brain.head.profile"
        }
    }
}

enum LessonDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "blue"
        case .advanced: return "orange"
        case .expert: return "red"
        }
    }
}

enum BigOComplexity: String, CaseIterable, Codable {
    case constant = "O(1)"
    case logarithmic = "O(log n)"
    case linear = "O(n)"
    case linearithmic = "O(n log n)"
    case quadratic = "O(n²)"
    case exponential = "O(2ⁿ)"
    
    var description: String {
        switch self {
        case .constant: return "Constant time - always takes the same time"
        case .logarithmic: return "Logarithmic time - cuts problem in half each step"
        case .linear: return "Linear time - proportional to input size"
        case .linearithmic: return "Linearithmic time - common in efficient sorting"
        case .quadratic: return "Quadratic time - nested loops over input"
        case .exponential: return "Exponential time - doubles with each input"
        }
    }
    
    var growthMultiplier: Double {
        switch self {
        case .constant: return 1.0
        case .logarithmic: return 0.3
        case .linear: return 1.0
        case .linearithmic: return 1.5
        case .quadratic: return 2.0
        case .exponential: return 3.0
        }
    }
}
