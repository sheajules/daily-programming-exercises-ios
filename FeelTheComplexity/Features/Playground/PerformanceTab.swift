import SwiftUI
import Charts

struct PerformanceTab: View {
    let simulationResult: SimulationResult?
    let inputSize: Int
    @State private var selectedComparison: ComparisonType = .growth
    
    var body: some View {
        VStack(spacing: 16) {
            if let result = simulationResult {
                // Comparison Type Selector
                ComparisonTypeSelector(
                    selectedType: $selectedComparison
                )
                .padding(.horizontal)
                
                // Performance Content
                TabView(selection: $selectedComparison) {
                    GrowthComparisonView(result: result, inputSize: inputSize)
                        .tag(ComparisonType.growth)
                    
                    BenchmarkView(result: result)
                        .tag(ComparisonType.benchmark)
                    
                    ScalingAnalysisView(result: result)
                        .tag(ComparisonType.scaling)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
            } else {
                // No Results State
                VStack(spacing: 16) {
                    Image(systemName: "speedometer")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Performance Data")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Run a simulation to analyze performance characteristics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
}

enum ComparisonType: String, CaseIterable {
    case growth = "growth"
    case benchmark = "benchmark"
    case scaling = "scaling"
    
    var title: String {
        switch self {
        case .growth: return "Growth"
        case .benchmark: return "Benchmark"
        case .scaling: return "Scaling"
        }
    }
    
    var systemImage: String {
        switch self {
        case .growth: return "chart.line.uptrend.xyaxis"
        case .benchmark: return "timer"
        case .scaling: return "arrow.up.and.down.text.horizontal"
        }
    }
}

struct ComparisonTypeSelector: View {
    @Binding var selectedType: ComparisonType
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(ComparisonType.allCases, id: \.self) { type in
                Button(action: {
                    selectedType = type
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: type.systemImage)
                            .font(.system(size: 14))
                        Text(type.title)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedType == type ? .blue : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct GrowthComparisonView: View {
    let result: SimulationResult
    let inputSize: Int
    
    private let comparisonSizes = [10, 50, 100, 500, 1000, 5000]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Growth Comparison")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Performance metrics for different input sizes
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(performanceMetrics, id: \.inputSize) { metric in
                        PerformanceMetricRow(metric: metric)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var performanceMetrics: [PerformanceMetric] {
        result.performanceMetrics(for: comparisonSizes)
    }
}

struct PerformanceMetricRow: View {
    let metric: PerformanceMetric
    
    var body: some View {
        HStack(spacing: 12) {
            Text("n=\(metric.inputSize)")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 60)
            
            Text("\(metric.operations)")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 80, alignment: .trailing)
            
            Text(metric.complexity.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(complexityColor(metric.complexity))
                .frame(width: 60)
            
            Text(String(format: "%.3f ms", metric.estimatedTime * 1000))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .trailing)
            
            Spacer()
        }
        .padding(.vertical, 4)
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

struct BenchmarkView: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benchmark Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                BenchmarkMetric(
                    title: "Total Operations",
                    value: "\(result.totalOperations)",
                    unit: "ops",
                    color: .blue
                )
                
                BenchmarkMetric(
                    title: "Execution Time",
                    value: String(format: "%.2f", result.executionTime * 1_000_000),
                    unit: "μs",
                    color: .green
                )
                
                BenchmarkMetric(
                    title: "Operations per Second",
                    value: String(format: "%.0f", Double(result.totalOperations) / result.executionTime),
                    unit: "ops/s",
                    color: .orange
                )
                
                BenchmarkMetric(
                    title: "Efficiency Score",
                    value: String(format: "%.1f", calculateEfficiencyScore()),
                    unit: "/100",
                    color: efficiencyScoreColor()
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func calculateEfficiencyScore() -> Double {
        let idealOperations = Double(result.inputSize) // Assuming linear is ideal baseline
        let actualOperations = Double(result.totalOperations)
        
        guard idealOperations > 0 else { return 0 }
        
        let score = max(0, min(100, 100 * (idealOperations / actualOperations)))
        return score
    }
    
    private func efficiencyScoreColor() -> Color {
        let score = calculateEfficiencyScore()
        if score >= 80 { return .green }
        if score >= 60 { return .yellow }
        if score >= 40 { return .orange }
        return .red
    }
}

struct BenchmarkMetric: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct ScalingAnalysisView: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Scaling Analysis")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("How this algorithm performs as input size increases")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Placeholder for scaling analysis chart
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .cornerRadius(8)
                .overlay(
                    VStack {
                        Text("📈 Scaling Chart")
                            .font(.title2)
                        Text("Shows performance across different input sizes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Insights")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("• \(result.complexity.description)")
                Text("• Best for \(recommendedUseCase())")
                Text("• Consider \(optimizationSuggestion())")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func recommendedUseCase() -> String {
        switch result.complexity {
        case .constant: return "fixed-size operations"
        case .logarithmic: return "search in sorted data"
        case .linear: return "single pass through data"
        case .linearithmic: return "efficient sorting"
        case .quadratic: return "small datasets only"
        case .exponential: return "very small inputs only"
        }
    }
    
    private func optimizationSuggestion() -> String {
        switch result.complexity {
        case .constant: return "current implementation is optimal"
        case .logarithmic: return "binary search techniques"
        case .linear: return "cache results if possible"
        case .linearithmic: return "consider specialized algorithms"
        case .quadratic: return "reduce nested loops"
        case .exponential: return "use dynamic programming"
        }
    }
}

#Preview {
    PerformanceTab(
        simulationResult: nil,
        inputSize: 100
    )
}
