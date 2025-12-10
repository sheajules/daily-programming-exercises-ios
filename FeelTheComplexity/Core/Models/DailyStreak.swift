import Foundation
import SwiftData

@Model
final class DailyStreak {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastPlayedDate: Date?
    var totalDaysPlayed: Int = 0
    var streakHistory: [StreakDay] = []
    var perfectWeeks: Int = 0
    var currentWeekProgress: [Bool] = Array(repeating: false, count: 7) // Sunday = 0, Saturday = 6
    
    init() {
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastPlayedDate = nil
        self.totalDaysPlayed = 0
        self.streakHistory = []
        self.perfectWeeks = 0
        self.currentWeekProgress = Array(repeating: false, count: 7)
    }
    
    func recordPlaySession() {
        let today = Calendar.current.startOfDay(for: Date())
        let calendar = Calendar.current
        
        // Check if this is the first time playing
        guard let lastPlayed = lastPlayedDate else {
            // First time playing
            currentStreak = 1
            longestStreak = 1
            lastPlayedDate = today
            totalDaysPlayed = 1
            addStreakDay(date: today, maintained: true)
            updateWeekProgress(for: today)
            return
        }
        
        let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
        let daysDifference = calendar.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
        
        if daysDifference == 0 {
            // Already played today, don't update streak
            return
        } else if daysDifference == 1 {
            // Consecutive day
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
            addStreakDay(date: today, maintained: true)
        } else {
            // Streak broken
            if daysDifference > 1 {
                addStreakDay(date: lastPlayedDay, maintained: false)
            }
            currentStreak = 1
            addStreakDay(date: today, maintained: true)
        }
        
        lastPlayedDate = today
        totalDaysPlayed += 1
        updateWeekProgress(for: today)
    }
    
    private func addStreakDay(date: Date, maintained: Bool) {
        let streakDay = StreakDay(date: date, maintained: maintained)
        streakHistory.append(streakDay)
        
        // Keep only last 365 days of history
        if streakHistory.count > 365 {
            streakHistory.removeFirst()
        }
        
        // Check for perfect week
        checkForPerfectWeek()
    }
    
    private func updateWeekProgress(for date: Date) {
        let weekday = Calendar.current.component(.weekday, from: date) - 1 // Convert to 0-6 (Sunday=0)
        currentWeekProgress[weekday] = true
        
        // Check if week is complete
        if currentWeekProgress.allSatisfy({ $0 }) {
            perfectWeeks += 1
            // Reset for next week
            currentWeekProgress = Array(repeating: false, count: 7)
        }
    }
    
    private func checkForPerfectWeek() {
        guard streakHistory.count >= 7 else { return }
        
        let lastSevenDays = Array(streakHistory.suffix(7))
        if lastSevenDays.allSatisfy({ $0.maintained }) {
            perfectWeeks += 1
        }
    }
    
    func getStreakForDate(_ date: Date) -> Bool {
        let targetDay = Calendar.current.startOfDay(for: date)
        return streakHistory.contains { streakDay in
            Calendar.current.isDate(streakDay.date, inSameDayAs: targetDay)
        }
    }
    
    func getWeeklyProgress() -> [Bool] {
        return currentWeekProgress
    }
    
    func getMonthlyProgress(for year: Int, month: Int) -> [Bool] {
        let calendar = Calendar.current
        var progress: [Bool] = []
        
        if let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
           let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) {
            
            let numberOfDays = calendar.dateComponents([.day], from: monthStart, to: monthEnd).day! + 1
            
            for day in 1...numberOfDays {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
                    progress.append(getStreakForDate(date))
                }
            }
        }
        
        return progress
    }
    
    func shouldShowStreakReminder() -> Bool {
        guard let lastPlayed = lastPlayedDate else { return true }
        
        let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
        let today = Calendar.current.startOfDay(for: Date())
        let daysDifference = Calendar.current.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
        
        return daysDifference >= 1
    }
    
    func resetDailyProgress() {
        // Called at midnight to prepare for new day
        let today = Calendar.current.startOfDay(for: Date())
        if let lastPlayed = lastPlayedDate {
            let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
            let daysDifference = Calendar.current.dateComponents([.day], from: lastPlayedDay, to: today).day ?? 0
            
            if daysDifference > 1 {
                currentStreak = 0
            }
        }
    }
}

@Model
final class StreakDay {
    var date: Date = Date()
    var maintained: Bool = false
    
    init(date: Date, maintained: Bool) {
        self.date = date
        self.maintained = maintained
    }
}

// MARK: - Streak Bonuses
extension DailyStreak {
    func getStreakBonusMultiplier() -> Double {
        switch currentStreak {
        case 0...2: return 1.0
        case 3...7: return 1.2
        case 8...14: return 1.5
        case 15...30: return 2.0
        case 31...60: return 2.5
        default: return 3.0
        }
    }
    
    func getStreakBonusXP(baseXP: Int) -> Int {
        return Int(Double(baseXP) * getStreakBonusMultiplier())
    }
}
