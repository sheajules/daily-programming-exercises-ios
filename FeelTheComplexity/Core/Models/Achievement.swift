import Foundation
import SwiftData

@Model
final class Achievement {
    var id: String = UUID().uuidString
    var title: String = ""
    var description: String = ""
    var icon: String = ""
    var category: AchievementCategory = .general
    var requirementType: AchievementRequirement = .xp
    var requirementValue: Int = 0
    var currentValue: Int = 0
    var isUnlocked: Bool = false
    var unlockedDate: Date?
    var xpReward: Int = 50
    var points: Int = 10
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        icon: String,
        category: AchievementCategory,
        requirementType: AchievementRequirement,
        requirementValue: Int,
        xpReward: Int = 50,
        points: Int = 10
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.category = category
        self.requirementType = requirementType
        self.requirementValue = requirementValue
        self.xpReward = xpReward
        self.points = points
    }
    
    func updateProgress(_ value: Int) {
        currentValue = value
        if currentValue >= requirementValue && !isUnlocked {
            isUnlocked = true
            unlockedDate = Date()
        }
    }
    
    func incrementProgress() {
        currentValue += 1
        if currentValue >= requirementValue && !isUnlocked {
            isUnlocked = true
            unlockedDate = Date()
        }
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case general = "General"
    case loops = "Loop Master"
    case recursion = "Recursion Whisperer"
    case dataStructures = "Data Structure Ninja"
    case optimization = "Growth Guru"
    case streaks = "Consistency Champion"
    case speed = "Speed Demon"
    
    var displayName: String {
        return self.rawValue
    }
    
    var icon: String {
        switch self {
        case .general: return "star.circle"
        case .loops: return "arrow.clockwise.circle"
        case .recursion: return "arrowtriangle.2.circlepath.circle"
        case .dataStructures: return "cube.box.circle"
        case .optimization: return "speedometer.circle"
        case .streaks: return "flame.circle"
        case .speed: return "bolt.circle"
        }
    }
}

enum AchievementRequirement: String, CaseIterable, Codable {
    case xp = "Total XP"
    case level = "Level Reached"
    case lessonsCompleted = "Lessons Completed"
    case streakDays = "Day Streak"
    case perfectLessons = "Perfect Lessons"
    case complexityMastered = "Complexity Mastered"
    case algorithmsAnalyzed = "Algorithms Analyzed"
    case speedRuns = "Speed Runs Completed"
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Predefined Achievements
extension Achievement {
    static let defaultAchievements: [Achievement] = [
        // XP Achievements
        Achievement(
            title: "First Steps",
            description: "Earn your first 50 XP",
            icon: "star.fill",
            category: .general,
            requirementType: .xp,
            requirementValue: 50
        ),
        Achievement(
            title: "Complexity Novice",
            description: "Earn 500 XP",
            icon: "star.circle.fill",
            category: .general,
            requirementType: .xp,
            requirementValue: 500
        ),
        Achievement(
            title: "Algorithm Expert",
            description: "Earn 2000 XP",
            icon: "star.circle.fill",
            category: .general,
            requirementType: .xp,
            requirementValue: 2000
        ),
        
        // Streak Achievements
        Achievement(
            title: "Daily Learner",
            description: "Maintain a 3-day streak",
            icon: "flame.fill",
            category: .streaks,
            requirementType: .streakDays,
            requirementValue: 3
        ),
        Achievement(
            title: "Week Warrior",
            description: "Maintain a 7-day streak",
            icon: "flame.fill",
            category: .streaks,
            requirementType: .streakDays,
            requirementValue: 7
        ),
        Achievement(
            title: "Month Master",
            description: "Maintain a 30-day streak",
            icon: "flame.fill",
            category: .streaks,
            requirementType: .streakDays,
            requirementValue: 30
        ),
        
        // Lesson Achievements
        Achievement(
            title: "First Lesson",
            description: "Complete your first lesson",
            icon: "checkmark.circle.fill",
            category: .general,
            requirementType: .lessonsCompleted,
            requirementValue: 1
        ),
        Achievement(
            title: "Loop Master",
            description: "Complete 10 loop lessons",
            icon: "arrow.clockwise.circle.fill",
            category: .loops,
            requirementType: .lessonsCompleted,
            requirementValue: 10
        ),
        Achievement(
            title: "Recursion Whisperer",
            description: "Complete 5 recursion lessons",
            icon: "arrowtriangle.2.circlepath.circle.fill",
            category: .recursion,
            requirementType: .lessonsCompleted,
            requirementValue: 5
        ),
        
        // Complexity Achievements
        Achievement(
            title: "O(1) Expert",
            description: "Master constant time complexity",
            icon: "1.circle.fill",
            category: .optimization,
            requirementType: .complexityMastered,
            requirementValue: 1
        ),
        Achievement(
            title: "O(n) Novice",
            description: "Master linear time complexity",
            icon: "n.circle.fill",
            category: .optimization,
            requirementType: .complexityMastered,
            requirementValue: 2
        ),
        Achievement(
            title: "O(log n) Logician",
            description: "Master logarithmic time complexity",
            icon: "log.circle.fill",
            category: .optimization,
            requirementType: .complexityMastered,
            requirementValue: 3
        )
    ]
}
