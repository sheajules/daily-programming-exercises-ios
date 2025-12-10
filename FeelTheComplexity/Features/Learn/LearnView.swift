import SwiftUI
import SwiftData

struct LearnView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lessons: [Lesson]
    @Query private var userProgress: [UserProgress]
    @State private var selectedCategory: LessonCategory = .loops
    
    private var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Selector
                LessonCategorySelector(
                    selectedCategory: $selectedCategory
                )
                .padding()
                .background(Color(.systemGray6))
                
                // Lessons List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredLessons) { lesson in
                            LessonCard(
                                lesson: lesson,
                                progress: progress
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadSampleLessons()
        }
    }
    
    private var filteredLessons: [Lesson] {
        lessons.filter { $0.category == selectedCategory }
            .sorted { $0.difficulty.rawValue < $1.difficulty.rawValue }
    }
    
    private func loadSampleLessons() {
        guard lessons.isEmpty else { return }
        
        // Create sample lessons for each category
        let sampleLessons = [
            // Linear Thinking
            Lesson(
                title: "Introduction to Loops",
                description: "Learn the basics of for loops and their complexity",
                category: .loops,
                difficulty: .beginner,
                complexity: .linear,
                codeSnippet: """
for i in 0..<n {
    print(i)
}
""",
                instructions: [
                    "Run the code with different input sizes",
                    "Observe how operations scale with input",
                    "Identify the Big-O complexity"
                ],
                expectedOutput: "Numbers from 0 to n-1",
                hint: "Think about how many times the loop runs"
            ),
            
            Lesson(
                title: "Nested Loops",
                description: "Understand why nested loops create quadratic complexity",
                category: .loops,
                difficulty: .intermediate,
                complexity: .quadratic,
                codeSnippet: """
for i in 0..<n {
    for j in 0..<n {
        print(i * j)
    }
}
""",
                instructions: [
                    "Analyze the nested loop structure",
                    "Count the total operations",
                    "Compare with single loop"
                ],
                expectedOutput: "Products of all pairs",
                hint: "Each outer iteration runs n inner iterations"
            ),
            
            // Logarithmic
            Lesson(
                title: "Binary Search",
                description: "Learn how divide and conquer creates logarithmic complexity",
                category: .logarithmic,
                difficulty: .intermediate,
                complexity: .logarithmic,
                codeSnippet: """
func binarySearch(_ array: [Int], target: Int) -> Int {
    var left = 0
    var right = array.count - 1
    
    while left <= right {
        let mid = (left + right) / 2
        if array[mid] == target {
            return mid
        } else if array[mid] < target {
            left = mid + 1
        } else {
            right = mid - 1
        }
    }
    return -1
}
""",
                instructions: [
                    "Understand the divide and conquer approach",
                    "Trace the algorithm with different inputs",
                    "Count how many times the search space halves"
                ],
                expectedOutput: "Index of target or -1",
                hint: "Each iteration cuts the search space in half"
            )
        ]
        
        for lesson in sampleLessons {
            modelContext.insert(lesson)
        }
    }
}

struct LessonCategorySelector: View {
    @Binding var selectedCategory: LessonCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LessonCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16))
                            
                            Text(category.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedCategory == category ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedCategory == category ? Color.blue : Color.clear)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct LessonCard: View {
    let lesson: Lesson
    let progress: UserProgress
    
    var isCompleted: Bool {
        progress.completedLessons.contains(lesson.id)
    }
    
    var isUnlocked: Bool {
        progress.unlockedFeatures.contains(lesson.category.rawValue) ||
        lesson.prerequisites.allSatisfy { prerequisite in
            progress.completedLessons.contains(prerequisite)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Badge(
                        text: lesson.difficulty.rawValue,
                        color: difficultyColor(lesson.difficulty)
                    )
                    
                    Badge(
                        text: lesson.complexity.rawValue,
                        color: complexityColor(lesson.complexity)
                    )
                }
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text("\(lesson.estimatedTime) min")
                        .font(.caption)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                    Text("\(lesson.xpReward) XP")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .stroke(
                    isCompleted ? Color.green : 
                    isUnlocked ? Color.blue : Color.gray,
                    lineWidth: isCompleted ? 2 : 1
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
        .overlay(
            isCompleted ? 
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
                .padding()
            } : nil
        )
    }
    
    private func difficultyColor(_ difficulty: LessonDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
    
    private func complexityColor(_ complexity: BigOComplexity) -> Color {
        switch complexity {
        case .constant: return .green
        case .logarithmic: return .blue
        case .linear: return .orange
        case .linearithmic: return .purple
        case .quadratic: return .red
        case .exponential: return .pink
        }
    }
}

#Preview {
    LearnView()
        .modelContainer(for: [Lesson.self, UserProgress.self], inMemory: true)
}
