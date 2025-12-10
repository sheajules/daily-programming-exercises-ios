import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    @Query private var dailyStreak: [DailyStreak]
    @State private var showingDailyPath = false
    @State private var showingLessonPicker = false
    
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
                    // Header with XP and Streak
                    HeaderSection(progress: progress, streak: streak)
                        .padding(.horizontal)
                    
                    // Daily Path CTA
                    DailyPathCard(progress: progress, streak: streak) {
                        showingDailyPath = true
                    }
                    .padding(.horizontal)
                    
                    // Quick Access Grid
                    QuickAccessGrid()
                        .padding(.horizontal)
                    
                    // Recent Activity
                    RecentActivitySection(progress: progress)
                        .padding(.horizontal)
                    
                    // Achievement Highlights
                    AchievementHighlights()
                        .padding(.horizontal)
                }
                .padding(.vertical, 20)
            }
            .navigationTitle("Feel the Complexity")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingDailyPath) {
            DailyPathView()
        }
        .sheet(isPresented: $showingLessonPicker) {
            LessonPickerView()
        }
    }
}

struct HeaderSection: View {
    let progress: UserProgress
    let streak: DailyStreak
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(progress.currentLevel)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(progress.totalXP) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak.currentStreak)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // XP Progress Bar
            ProgressView(value: Double(progress.totalXP % 100), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 2)
                .padding(.horizontal)
            
            HStack {
                Text("\(progress.totalXP % 100)/100 XP to next level")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct DailyPathCard: View {
    let progress: UserProgress
    let streak: DailyStreak
    let onStartDailyPath: () -> Void
    
    private var canStartDailyPath: Bool {
        progress.currentHearts > 0
    }
    
    var body: some View {
        Button(action: onStartDailyPath) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Daily Path")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Continue your complexity journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                HStack(spacing: 24) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(progress.currentHearts)")
                            .fontWeight(.semibold)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                        Text("5 min")
                            .fontWeight(.semibold)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(streak.getStreakBonusXP(baseXP: 10)) XP")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .background(canStartDailyPath ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(canStartDailyPath ? Color.blue : Color.gray, lineWidth: 2)
            )
        }
        .disabled(!canStartDailyPath)
        .opacity(canStartDailyPath ? 1.0 : 0.6)
    }
}

struct QuickAccessGrid: View {
    private let features = [
        FeatureItem(
            title: "Playground",
            description: "Experiment with code",
            icon: "play.circle.fill",
            color: .blue
        ),
        FeatureItem(
            title: "Code Surgery",
            description: "Optimize algorithms",
            icon: "stethoscope",
            color: .green
        ),
        FeatureItem(
            title: "Algorithm Duels",
            description: "Race algorithms",
            icon: "flag.checkered",
            color: .orange
        ),
        FeatureItem(
            title: "Heatmap Viewer",
            description: "Visualize execution",
            icon: "grid.circle",
            color: .purple
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Access")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(features) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct FeatureCard: View {
    let feature: FeatureItem
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.system(size: 32))
                .foregroundColor(feature.color)
            
            VStack(spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecentActivitySection: View {
    let progress: UserProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            if progress.completedLessons.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No lessons completed yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Start your Daily Path to begin learning")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else {
                // TODO: Implement recent activity display
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed Linear Basics")
                            .font(.subheadline)
                        Spacer()
                        Text("2h ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Completed Loops Introduction")
                            .font(.subheadline)
                        Spacer()
                        Text("1d ago")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

struct AchievementHighlights: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievement Highlights")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AchievementCard(
                        title: "First Steps",
                        description: "Complete your first lesson",
                        icon: "star.fill",
                        color: .yellow,
                        isUnlocked: false
                    )
                    
                    AchievementCard(
                        title: "Daily Learner",
                        description: "3-day streak",
                        icon: "flame.fill",
                        color: .orange,
                        isUnlocked: false
                    )
                    
                    AchievementCard(
                        title: "Loop Master",
                        description: "Complete 10 loop lessons",
                        icon: "arrow.clockwise.circle.fill",
                        color: .blue,
                        isUnlocked: false
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}

struct AchievementCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isUnlocked ? color : .gray)
                .opacity(isUnlocked ? 1.0 : 0.5)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isUnlocked ? color : Color.gray, lineWidth: isUnlocked ? 2 : 1)
                .opacity(isUnlocked ? 1.0 : 0.5)
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [UserProgress.self, DailyStreak.self, Lesson.self, Achievement.self], inMemory: true)
}
