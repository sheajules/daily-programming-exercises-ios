import Foundation
import SwiftData

@Model
final class UserProgress {
    var totalXP: Int = 0
    var currentLevel: Int = 1
    var currentHearts: Int = 5
    var lastPlayDate: Date = Date()
    var completedLessons: [String] = []
    var unlockedFeatures: [String] = []
    var preferences: UserPreferences = UserPreferences()
    
    init() {
        self.totalXP = 0
        self.currentLevel = 1
        self.currentHearts = 5
        self.lastPlayDate = Date()
        self.completedLessons = []
        self.unlockedFeatures = ["home", "playground"]
        self.preferences = UserPreferences()
    }
    
    func addXP(_ amount: Int) {
        totalXP += amount
        updateLevel()
    }
    
    func loseHeart() -> Bool {
        if currentHearts > 0 {
            currentHearts -= 1
            return true
        }
        return false
    }
    
    func refillHearts() {
        currentHearts = 5
    }
    
    private func updateLevel() {
        let newLevel = (totalXP / 100) + 1
        if newLevel > currentLevel {
            currentLevel = newLevel
        }
    }
    
    func markLessonCompleted(_ lessonId: String) {
        if !completedLessons.contains(lessonId) {
            completedLessons.append(lessonId)
            addXP(10)
        }
    }
}

struct UserPreferences: Codable {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var animationsEnabled: Bool = true
    var reducedMotion: Bool = false
    var highContrast: Bool = false
    var voiceOverEnabled: Bool = false
}
