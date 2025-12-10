import SwiftUI

struct CodeEditorTab: View {
    @Binding var codeInput: String
    @Binding var inputSize: Double
    @Binding var simulationResult: SimulationResult?
    @Binding var isSimulating: Bool
    let onSimulate: () -> Void
    let codeExamples: [CodeExample]
    
    @State private var showingExamples = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Code Examples Button
            HStack {
                Button("Code Examples") {
                    showingExamples = true
                }
                .buttonStyle(.bordered)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Code Editor
            VStack(alignment: .leading, spacing: 8) {
                Text("Swift Code")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextEditor(text: $codeInput)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            
            // Input Size Slider
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Input Size (n)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(Int(inputSize))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }
                
                Slider(value: $inputSize, in: 1...10000, step: 1) {
                    Text("Input Size")
                } minimumValueLabel: {
                    Text("1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } maximumValueLabel: {
                    Text("10K")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Quick size presets
                HStack {
                    ForEach([10, 100, 1000, 5000], id: \.self) { size in
                        Button("\(size)") {
                            inputSize = Double(size)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
            
            // Simulation Result Summary
            if let result = simulationResult {
                SimulationResultSummary(result: result)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .sheet(isPresented: $showingExamples) {
            CodeExamplesSheet(
                examples: codeExamples,
                onSelectExample: { example in
                    codeInput = example.code
                    showingExamples = false
                }
            )
        }
    }
}

struct SimulationResultSummary: View {
    let result: SimulationResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Simulation Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Complexity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(result.complexity.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(complexityColor(result.complexity))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Operations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(result.totalOperations)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2fμs", result.executionTime * 1_000_000))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            Text(result.complexity.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

struct CodeExamplesSheet: View {
    let examples: [CodeExample]
    let onSelectExample: (CodeExample) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(examples) { example in
                Button(action: { onSelectExample(example) }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(example.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Badge(text: example.complexity.rawValue, 
                                  color: complexityColor(example.complexity))
                        }
                        
                        Text(example.code)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Code Examples")
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

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(6)
    }
}

#Preview {
    CodeEditorTab(
        codeInput: .constant("for i in 0..<n {\n    print(i)\n}"),
        inputSize: .constant(100),
        simulationResult: .constant(nil),
        isSimulating: .constant(false),
        onSimulate: {},
        codeExamples: []
    )
}
