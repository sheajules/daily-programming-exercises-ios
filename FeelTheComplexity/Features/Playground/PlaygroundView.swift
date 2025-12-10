import SwiftUI
import SwiftData

struct PlaygroundView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var codeInput: String = """
for i in 0..<n {
    print(i)
}
"""
    @State private var inputSize: Double = 100
    @State private var simulationResult: SimulationResult?
    @State private var isSimulating = false
    @State private var showingHeatmap = false
    @State private var selectedTab: PlaygroundTab = .editor
    
    private let codeExamples = [
        CodeExample(
            title: "Linear Loop",
            code: "for i in 0..<n {\n    print(i)\n}",
            complexity: .linear
        ),
        CodeExample(
            title: "Nested Loop",
            code: "for i in 0..<n {\n    for j in 0..<n {\n        print(i * j)\n    }\n}",
            complexity: .quadratic
        ),
        CodeExample(
            title: "Binary Search",
            code: "func binarySearch(_ array: [Int], target: Int) -> Int {\n    var left = 0\n    var right = array.count - 1\n    \n    while left <= right {\n        let mid = (left + right) / 2\n        if array[mid] == target {\n            return mid\n        } else if array[mid] < target {\n            left = mid + 1\n        } else {\n            right = mid - 1\n        }\n    }\n    return -1\n}",
            complexity: .logarithmic
        ),
        CodeExample(
            title: "Quick Sort",
            code: "func quickSort(_ array: [Int]) -> [Int] {\n    guard array.count > 1 else { return array }\n    \n    let pivot = array[array.count / 2]\n    let left = array.filter { $0 < pivot }\n    let middle = array.filter { $0 == pivot }\n    let right = array.filter { $0 > pivot }\n    \n    return quickSort(left) + middle + quickSort(right)\n}",
            complexity: .linearithmic
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                PlaygroundTabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    // Code Editor Tab
                    CodeEditorTab(
                        codeInput: $codeInput,
                        inputSize: $inputSize,
                        simulationResult: $simulationResult,
                        isSimulating: $isSimulating,
                        onSimulate: simulateCode,
                        codeExamples: codeExamples
                    )
                    .tag(PlaygroundTab.editor)
                    
                    // Visualization Tab
                    VisualizationTab(
                        simulationResult: simulationResult,
                        inputSize: Int(inputSize),
                        showingHeatmap: $showingHeatmap
                    )
                    .tag(PlaygroundTab.visualization)
                    
                    // Performance Tab
                    PerformanceTab(
                        simulationResult: simulationResult,
                        inputSize: Int(inputSize)
                    )
                    .tag(PlaygroundTab.performance)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Code Playground")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simulate") {
                        simulateCode()
                    }
                    .disabled(isSimulating || codeInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .sheet(isPresented: $showingHeatmap) {
            if let result = simulationResult {
                HeatmapView(result: result)
            }
        }
    }
    
    private func simulateCode() {
        isSimulating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let result = ComplexitySimulationEngine.shared.analyze(
                code: codeInput,
                inputSize: Int(inputSize)
            )
            
            simulationResult = result
            isSimulating = false
            
            // Auto-switch to visualization tab after simulation
            selectedTab = .visualization
        }
    }
}

enum PlaygroundTab: String, CaseIterable {
    case editor = "editor"
    case visualization = "visualization"
    case performance = "performance"
    
    var title: String {
        switch self {
        case .editor: return "Code"
        case .visualization: return "Visualize"
        case .performance: return "Performance"
        }
    }
    
    var systemImage: String {
        switch self {
        case .editor: return "square.and.pencil"
        case .visualization: return "chart.xyaxis.line"
        case .performance: return "speedometer"
        }
    }
}

struct CodeExample {
    let title: String
    let code: String
    let complexity: BigOComplexity
}

struct PlaygroundTabSelector: View {
    @Binding var selectedTab: PlaygroundTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PlaygroundTab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 16, weight: selectedTab == tab ? .bold : .regular))
                        
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                    }
                    .foregroundColor(selectedTab == tab ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    PlaygroundView()
        .modelContainer(for: [UserProgress.self, DailyStreak.self, Lesson.self], inMemory: true)
}
