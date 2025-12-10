import SwiftUI
import SwiftData

struct LessonPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var lessons: [Lesson]
    @Query private var userProgress: [UserProgress]
    @State private var selectedCategory: LessonCategory = .loops
    @State private var searchText = ""
    
    private var progress: UserProgress {
        userProgress.first ?? UserProgress()
    }
    
    private var filteredLessons: [Lesson] {
        let categoryFiltered = lessons.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered.sorted { $0.difficulty.rawValue < $1.difficulty.rawValue }
        } else {
            return categoryFiltered.filter { lesson in
                lesson.title.localizedCaseInsensitiveContains(searchText) ||
                lesson.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 16) {
                    SearchBar(text: $searchText)
                    
                    CategoryFilter(
                        selectedCategory: $selectedCategory
                    )
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Lessons List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredLessons) { lesson in
                            LessonPickerCard(
                                lesson: lesson,
                                progress: progress,
                                onSelect: {
                                    dismiss()
                                    // TODO: Navigate to lesson detail
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Choose Lesson")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search lessons...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct CategoryFilter: View {
    @Binding var selectedCategory: LessonCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LessonCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14))
                            
                            Text(category.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(selectedCategory == category ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
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

struct LessonPickerCard: View {
    let lesson: Lesson
    let progress: UserProgress
    let onSelect: () -> Void
    
    var isCompleted: Bool {
        progress.completedLessons.contains(lesson.id)
    }
    
    var isUnlocked: Bool {
        lesson.prerequisites.allSatisfy { prerequisite in
            progress.completedLessons.contains(prerequisite)
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : isUnlocked ? Color.blue : Color.gray)
                        .frame(width: 24, height: 24)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: isUnlocked ? "play" : "lock")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Lesson Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(isUnlocked ? .primary : .secondary)
                    
                    Text(lesson.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text("\(lesson.estimatedTime) min")
                                .font(.caption2)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text("\(lesson.xpReward) XP")
                                .font(.caption2)
                        }
                        
                        Badge(
                            text: lesson.complexity.rawValue,
                            color: complexityColor(lesson.complexity)
                        )
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
            }
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
        .disabled(!isUnlocked)
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
    LessonPickerView()
        .modelContainer(for: [Lesson.self, UserProgress.self], inMemory: true)
}
