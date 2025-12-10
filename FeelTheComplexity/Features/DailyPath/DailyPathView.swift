import SwiftUI
import SwiftData

struct DailyPathView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    @Query private var dailyStreak: [DailyStreak]
    @State private var currentLessonIndex = 0
    @State private var isCompletingLesson = false
    
    private var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    private var streak: DailyStreak {
        dailyStreak.first ?? DailyStreak()
    }
    
    private let dailyLessons = [
        DailyLesson(
            id: "daily-1",
            title: "Loop Intuition",
            description: "Practice recognizing linear loops",
            type: .loopPractice,
            difficulty: .beginner,
            estimatedTime: 3
        ),
        DailyLesson(
            id: "daily-2",
            title: "Nested Patterns",
            description: "Identify quadratic complexity",
            type: .patternRecognition,
            difficulty: .intermediate,
            estimatedTime: 5
        ),
        DailyLesson(
            id: "daily-3",
            title: "Optimization Challenge",
            description: "Improve algorithm efficiency",
            type: .optimization,
            difficulty: .advanced,
            estimatedTime: 7
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Path")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Continue your complexity journey")
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
                    
                    // Progress Bar
                    ProgressView(value: Double(currentLessonIndex), total: Double(dailyLessons.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 2)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Current Lesson
                if currentLessonIndex < dailyLessons.count {
                    let currentLesson = dailyLessons[currentLessonIndex]
                    
                    DailyLessonCard(
                        lesson: currentLesson,
                        onComplete: {
                            completeLesson(currentLesson)
                        },
                        isCompleting: isCompletingLesson,
                        progress: progress,
                        streak: streak
                    )
                    .padding(.horizontal)
                }
                
                // Completed Lessons
                if currentLessonIndex > 0 {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Completed Today")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(dailyLessons.prefix(currentLessonIndex).enumerated()), id: \.offset) { index, lesson in
                                    CompletedDailyLessonCard(lesson: lesson)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Daily Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .disabled(isCompletingLesson)
    }
    
    private func completeLesson(_ lesson: DailyLesson) {
        isCompletingLesson = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Update progress
            progress.addXP(lesson.xpReward)
            progress.markLessonCompleted(lesson.id)
            
            // Update streak
            streak.recordPlaySession()
            
            // Move to next lesson
            currentLessonIndex += 1
            isCompletingLesson = false
        }
    }
}

struct DailyLesson {
    let id: String
    let title: String
    let description: String
    let type: DailyLessonType
    let difficulty: LessonDifficulty
    let estimatedTime: Int
    
    var xpReward: Int {
        switch difficulty {
        case .beginner: return 10
        case .intermediate: return 20
        case .advanced: return 30
        case .expert: return 50
        }
    }
}

enum DailyLessonType {
    case loopPractice
    case patternRecognition
    case optimization
    case memoryTrace
    case algorithmDuel
    
    var icon: String {
        switch self {
        case .loopPractice: return "arrow.clockwise.circle"
        case .patternRecognition: return "eye.circle"
        case .optimization: return "speedometer.circle"
        case .memoryTrace: return "cpu.circle"
        case .algorithmDuel: return "flag.checkered.circle"
        }
    }
    
    var title: String {
        switch self {
        case .loopPractice: return "Loop Practice"
        case .patternRecognition: return "Pattern Recognition"
        case .optimization: return "Optimization"
        case .memoryTrace: return "Memory Trace"
        case .algorithmDuel: return "Algorithm Duel"
        }
    }
}

struct DailyLessonCard: View {
    let lesson: DailyLesson
    let onComplete: () -> Void
    let isCompleting: Bool
    let progress: UserProgress
    let streak: DailyStreak
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(lesson.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(lesson.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: lesson.type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 24) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(lesson.estimatedTime) min")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("+\(lesson.xpReward + streak.getStreakBonusXP(baseXP: lesson.xpReward)) XP")
                        .font(.caption)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                    Text("\(progress.currentHearts)")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            
            Button(action: onComplete) {
                HStack {
                    if isCompleting {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Completing...")
                            .fontWeight(.semibold)
                    } else {
                        Image(systemName: "play.fill")
                        Text("Start Lesson")
                            .fontWeight(.semibold)
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(isCompleting || progress.currentHearts == 0)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct CompletedDailyLessonCard: View {
    let lesson: DailyLesson
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.green)
            
            Text(lesson.title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("+\(lesson.xpReward) XP")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DailyPathView()
        .modelContainer(for: [UserProgress.self, DailyStreak.self], inMemory: true)
}
