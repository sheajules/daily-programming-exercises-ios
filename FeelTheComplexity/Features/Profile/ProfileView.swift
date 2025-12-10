import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    @Query private var dailyStreak: [DailyStreak]
    @Query private var achievements: [Achievement]
    @State private var showingSettings = false
    
    private var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    private var streak: DailyStreak {
        dailyStreak.first ?? DailyStreak()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Profile Header
                    ProfileHeader(progress: progress, streak: streak)
                        .padding(.horizontal)
                    
                    // Stats Grid
                    StatsGrid(progress: progress, streak: streak)
                        .padding(.horizontal)
                    
                    // Achievements Section
                    AchievementsSection(achievements: achievements)
                        .padding(.horizontal)
                    
                    // Settings Button
                    SettingsButton {
                        showingSettings = true
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(progress: progress)
        }
    }
}

struct ProfileHeader: View {
    let progress: UserProgress
    let streak: DailyStreak
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar and Level
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Text("FC")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 4) {
                    Text("Complexity Learner")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Level \(progress.currentLevel)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            
            // Progress to Next Level
            VStack(spacing: 8) {
                HStack {
                    Text("Progress to Level \(progress.currentLevel + 1)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(progress.totalXP % 100)/100 XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(progress.totalXP % 100), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 1.5)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct StatsGrid: View {
    let progress: UserProgress
    let streak: DailyStreak
    
    private let stats = [
        StatItem(title: "Total XP", value: "1,234", icon: "star.fill", color: .yellow),
        StatItem(title: "Lessons", value: "12", icon: "book.fill", color: .blue),
        StatItem(title: "Streak", value: "5 days", icon: "flame.fill", color: .orange),
        StatItem(title: "Achievements", value: "8/25", icon: "trophy.fill", color: .purple)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(stats) { stat in
                    StatCard(stat: stat)
                }
            }
        }
    }
}

struct StatItem: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct StatCard: View {
    let stat: StatItem
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: stat.icon)
                .font(.system(size: 24))
                .foregroundColor(stat.color)
            
            VStack(spacing: 2) {
                Text(stat.value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(stat.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AchievementsSection: View {
    let achievements: [Achievement]
    
    private var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    private var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(unlockedAchievements.count)/\(achievements.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            if !unlockedAchievements.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(unlockedAchievements.prefix(5)) { achievement in
                            AchievementCompactCard(achievement: achievement, isUnlocked: true)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if lockedAchievements.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("All Achievements Unlocked!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("You've mastered complexity analysis")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

struct AchievementCompactCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.system(size: 24))
                .foregroundColor(isUnlocked ? achievement.category.color : .gray)
                .opacity(isUnlocked ? 1.0 : 0.5)
            
            VStack(spacing: 2) {
                Text(achievement.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                
                Text("\(achievement.currentValue)/\(achievement.requirementValue)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SettingsButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "gearshape.fill")
                Text("Settings")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct SettingsView: View {
    let progress: UserProgress
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var hapticsEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Learning Preferences") {
                    Toggle("Daily Reminders", isOn: $notificationsEnabled)
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                }
                
                Section("Account") {
                    Button("Reset Progress") {
                        // TODO: Implement reset functionality
                    }
                    .foregroundColor(.red)
                    
                    Button("Export Data") {
                        // TODO: Implement export functionality
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserProgress.self, DailyStreak.self, Achievement.self], inMemory: true)
}
