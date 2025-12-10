import SwiftUI

struct HeatmapView: View {
    let result: SimulationResult
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLine: Int?
    @State private var showLineNumbers = true
    @State private var showExecutionCount = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Heatmap Controls
                HeatmapControls(
                    showLineNumbers: $showLineNumbers,
                    showExecutionCount: $showExecutionCount
                )
                .padding()
                .background(Color(.systemGray6))
                
                // Code with Heatmap
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(result.code.components(separatedBy: .newlines).enumerated()), id: \.offset) { index, line in
                            HeatmapLineView(
                                lineNumber: index + 1,
                                code: line,
                                heatmapData: result.heatmap.first { $0.lineNumber == index + 1 },
                                isSelected: selectedLine == index + 1,
                                showLineNumbers: showLineNumbers,
                                showExecutionCount: showExecutionCount
                            )
                            .onTapGesture {
                                selectedLine = selectedLine == index + 1 ? nil : index + 1
                            }
                        }
                    }
                    .padding()
                }
                
                // Legend
                HeatmapLegend()
                    .padding()
                    .background(Color(.systemGray6))
            }
            .navigationTitle("Execution Heatmap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Export Heatmap") {
                            exportHeatmap()
                        }
                        
                        Button("Share Analysis") {
                            shareAnalysis()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    private func exportHeatmap() {
        // TODO: Implement heatmap export
        print("Exporting heatmap...")
    }
    
    private func shareAnalysis() {
        // TODO: Implement sharing functionality
        print("Sharing analysis...")
    }
}

struct HeatmapControls: View {
    @Binding var showLineNumbers: Bool
    @Binding var showExecutionCount: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Toggle("Line Numbers", isOn: $showLineNumbers)
                .toggleStyle(.switch)
            
            Toggle("Execution Count", isOn: $showExecutionCount)
                .toggleStyle(.switch)
            
            Spacer()
        }
        .font(.caption)
    }
}

struct HeatmapLineView: View {
    let lineNumber: Int
    let code: String
    let heatmapData: HeatmapData?
    let isSelected: Bool
    let showLineNumbers: Bool
    let showExecutionCount: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            if showLineNumbers {
                Text("\(lineNumber)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .trailing)
                    .padding(.trailing, 8)
            }
            
            // Heatmap background
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(backgroundColor)
                    .frame(maxWidth: .infinity, minHeight: 24)
                
                Text(code.isEmpty ? " " : code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(textColor)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
            }
            
            if showExecutionCount, let data = heatmapData {
                Text("\(data.executionCount)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
                    .padding(.leading, 8)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        )
    }
    
    private var backgroundColor: Color {
        guard let data = heatmapData else { return Color.clear }
        return heatColor(for: data.intensity)
    }
    
    private var textColor: Color {
        guard let data = heatmapData else { return Color.primary }
        return data.intensity > 0.5 ? Color.white : Color.primary
    }
    
    private func heatColor(for intensity: Double) -> Color {
        switch intensity {
        case 0.0..<0.1:
            return Color.clear
        case 0.1..<0.2:
            return Color.green.opacity(0.3)
        case 0.2..<0.3:
            return Color.green.opacity(0.5)
        case 0.3..<0.4:
            return Color.yellow.opacity(0.3)
        case 0.4..<0.5:
            return Color.yellow.opacity(0.5)
        case 0.5..<0.6:
            return Color.orange.opacity(0.3)
        case 0.6..<0.7:
            return Color.orange.opacity(0.5)
        case 0.7..<0.8:
            return Color.red.opacity(0.3)
        case 0.8..<0.9:
            return Color.red.opacity(0.5)
        default:
            return Color.red.opacity(0.7)
        }
    }
}

struct HeatmapLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Execution Frequency")
                .font(.caption)
                .fontWeight(.semibold)
            
            HStack(spacing: 4) {
                legendItem(color: .clear, label: "0%")
                legendItem(color: .green.opacity(0.3), label: "10%")
                legendItem(color: .yellow.opacity(0.5), label: "40%")
                legendItem(color: .orange.opacity(0.5), label: "60%")
                legendItem(color: .red.opacity(0.5), label: "80%")
                legendItem(color: .red.opacity(0.7), label: "100%")
            }
        }
    }
    
    private func legendItem(color: Color, label: String) -> some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(color)
                .frame(width: 20, height: 12)
                .border(Color.gray.opacity(0.3), width: 0.5)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Line Detail Sheet

struct LineDetailSheet: View {
    let lineNumber: Int
    let heatmapData: HeatmapData?
    let code: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Line \(lineNumber)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if let data = heatmapData {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Executions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(data.executionCount)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Frequency")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(data.intensity * 100))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Code")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(code)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                
                if let data = heatmapData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Analysis")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(executionAnalysis(for: data))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Line Details")
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
    
    private func executionAnalysis(for data: HeatmapData) -> String {
        if data.executionCount == 1 {
            return "This line executes once, indicating a constant-time operation."
        } else if data.intensity > 0.5 {
            return "This line executes frequently and may be a performance bottleneck."
        } else if data.intensity > 0.2 {
            return "This line executes moderately often."
        } else {
            return "This line executes relatively infrequently."
        }
    }
}

#Preview {
    // Create a mock result for preview
    let mockResult = SimulationResult(
        code: "for i in 0..<n {\n    print(i)\n    for j in 0..<n {\n        print(i * j)\n    }\n}",
        inputSize: 100,
        ast: CodeAST(nodes: []),
        executionTrace: ExecutionTrace(
            totalOperations: 10100,
            lineExecutions: [1: 100, 2: 100, 3: 10000, 4: 10000],
            animationFrames: [],
            inputSize: 100
        ),
        complexity: .quadratic,
        heatmap: [
            HeatmapData(lineNumber: 1, intensity: 0.01, executionCount: 100),
            HeatmapData(lineNumber: 2, intensity: 0.01, executionCount: 100),
            HeatmapData(lineNumber: 3, intensity: 0.99, executionCount: 10000),
            HeatmapData(lineNumber: 4, intensity: 0.99, executionCount: 10000)
        ],
        totalOperations: 10100,
        executionTime: 0.0101
    )
    
    return HeatmapView(result: mockResult)
}
