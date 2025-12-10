import SwiftUI

struct VisualizationTab: View {
    let simulationResult: SimulationResult?
    let inputSize: Int
    @Binding var showingHeatmap: Bool
    @State private var selectedVisualization: VisualizationType = .animation
    
    var body: some View {
        VStack(spacing: 16) {
            if let result = simulationResult {
                // Visualization Type Selector
                VisualizationTypeSelector(
                    selectedType: $selectedVisualization
                )
                .padding(.horizontal)
                
                // Visualization Content
                TabView(selection: $selectedVisualization) {
                    // Animation Visualization
                    AnimationVisualization(result: result)
                        .tag(VisualizationType.animation)
                    
                    // Step Counter Visualization
                    StepCounterVisualization(result: result)
                        .tag(VisualizationType.steps)
                    
                    // Growth Curve Visualization
                    GrowthCurveVisualization(result: result)
                        .tag(VisualizationType.growth)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Heatmap Button
                Button("View Heatmap") {
                    showingHeatmap = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Spacer()
            } else {
                // No Results State
                VStack(spacing: 16) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("No Simulation Results")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Run a simulation in the Code tab to see visualizations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Go to Code") {
                        // This would switch tabs - would need to be handled by parent
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

enum VisualizationType: String, CaseIterable {
    case animation = "animation"
    case steps = "steps"
    case growth = "growth"
    
    var title: String {
        switch self {
        case .animation: return "Animation"
        case .steps: return "Steps"
        case .growth: return "Growth"
        }
    }
    
    var systemImage: String {
        switch self {
        case .animation: return "play.circle"
        case .steps: return "list.number"
        case .growth: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct VisualizationTypeSelector: View {
    @Binding var selectedType: VisualizationType
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(VisualizationType.allCases, id: \.self) { type in
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

struct AnimationVisualization: View {
    let result: SimulationResult
    @State private var isAnimating = false
    @State private var currentStep = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Execution Animation")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    if isAnimating {
                        stopAnimation()
                    } else {
                        startAnimation()
                    }
                }) {
                    Image(systemName: isAnimating ? "pause.fill" : "play.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // Animation Display
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(result.executionTrace.animationFrames.enumerated()), id: \.offset) { index, frame in
                        AnimationFrameView(
                            frame: frame,
                            isActive: index == currentStep && isAnimating
                        )
                    }
                }
            }
            .frame(maxHeight: 300)
            
            // Progress Indicator
            if !result.executionTrace.animationFrames.isEmpty {
                ProgressView(
                    value: Double(currentStep),
                    total: Double(result.executionTrace.animationFrames.count - 1)
                )
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        guard !result.executionTrace.animationFrames.isEmpty else { return }
        
        isAnimating = true
        currentStep = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if currentStep < result.executionTrace.animationFrames.count - 1 {
                currentStep += 1
            } else {
                stopAnimation()
                timer.invalidate()
            }
        }
    }
    
    private func stopAnimation() {
        isAnimating = false
    }
}

struct AnimationFrameView: View {
    let frame: AnimationFrame
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Line \(frame.lineNumber)")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("\(frame.operations) ops")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 60)
            
            VStack(spacing: 4) {
                Text(frame.complexity.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(complexityColor(frame.complexity))
                Text(String(format: "%.1fs", frame.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Rectangle()
                .fill(complexityColor(frame.complexity))
                .frame(width: CGFloat(frame.operations) / 100, height: 20)
                .cornerRadius(4)
            
            Spacer()
        }
        .padding(8)
        .background(isActive ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
        )
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

struct StepCounterVisualization: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Step Counter")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(result.executionTrace.lineExecutions.sorted(by: { $0.key < $1.key })), id: \.key) { lineNumber, executionCount in
                        StepCounterRow(
                            lineNumber: lineNumber,
                            executionCount: executionCount,
                            totalOperations: result.executionTrace.totalOperations
                        )
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StepCounterRow: View {
    let lineNumber: Int
    let executionCount: Int
    let totalOperations: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text("Line \(lineNumber)")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 60)
            
            Text("\(executionCount)×")
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 60)
            
            // Visual bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(height: 20)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(percentageColor)
                        .frame(
                            width: geometry.size.width * percentage,
                            height: 20
                        )
                        .cornerRadius(4)
                }
            }
            .frame(height: 20)
            
            Text("\(Int(percentage * 100))%")
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 40)
        }
        .padding(.vertical, 4)
    }
    
    private var percentage: Double {
        guard totalOperations > 0 else { return 0 }
        return Double(executionCount) / Double(totalOperations)
    }
    
    private var percentageColor: Color {
        if percentage > 0.5 { return .red }
        if percentage > 0.3 { return .orange }
        if percentage > 0.1 { return .yellow }
        return .green
    }
}

struct GrowthCurveVisualization: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Growth Curve")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Placeholder for growth curve chart
            Text("Growth curve visualization would show how operations scale with input size")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 200)
                .cornerRadius(8)
                .overlay(
                    Text("📊 Growth Chart")
                        .font(.title)
                )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VisualizationTab(
        simulationResult: nil,
        inputSize: 100,
        showingHeatmap: .constant(false)
    )
}
