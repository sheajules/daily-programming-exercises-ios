import Foundation

/// Core engine for analyzing and simulating code complexity
class ComplexitySimulationEngine {
    static let shared = ComplexitySimulationEngine()
    
    private init() {}
    
    /// Analyzes code and returns execution simulation results
    func analyze(code: String, inputSize: Int) -> SimulationResult {
        let ast = parseCode(code)
        let executionTrace = simulateExecution(ast: ast, inputSize: inputSize)
        let complexity = determineComplexity(executionTrace: executionTrace)
        let heatmap = generateHeatmap(executionTrace: executionTrace)
        
        return SimulationResult(
            code: code,
            inputSize: inputSize,
            ast: ast,
            executionTrace: executionTrace,
            complexity: complexity,
            heatmap: heatmap,
            totalOperations: executionTrace.totalOperations,
            executionTime: calculateEstimatedTime(executionTrace: executionTrace, inputSize: inputSize)
        )
    }
    
    /// Parses simplified Swift code into an AST
    private func parseCode(_ code: String) -> CodeAST {
        let lines = code.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var nodes: [ASTNode] = []
        var lineNumber = 1
        
        for line in lines {
            if let node = parseLine(line, lineNumber: lineNumber) {
                nodes.append(node)
            }
            lineNumber += 1
        }
        
        return CodeAST(nodes: nodes)
    }
    
    /// Parses individual lines of code into AST nodes
    private func parseLine(_ line: String, lineNumber: Int) -> ASTNode? {
        // Simple parsing for common patterns
        if line.hasPrefix("for") {
            return parseForLoop(line, lineNumber: lineNumber)
        } else if line.hasPrefix("while") {
            return parseWhileLoop(line, lineNumber: lineNumber)
        } else if line.hasPrefix("if") {
            return parseIfStatement(line, lineNumber: lineNumber)
        } else if line.contains("=") {
            return parseAssignment(line, lineNumber: lineNumber)
        } else if line.contains("func") {
            return parseFunctionCall(line, lineNumber: lineNumber)
        }
        
        return nil
    }
    
    private func parseForLoop(_ line: String, lineNumber: Int) -> ASTNode {
        // Simple for loop parsing: "for i in 0..<n"
        let complexity = line.contains("..<n") ? .linear : 
                        line.contains("n*n") ? .quadratic : .constant
        
        return ASTNode(
            type: .forLoop,
            content: line,
            lineNumber: lineNumber,
            complexity: complexity,
            children: []
        )
    }
    
    private func parseWhileLoop(_ line: String, lineNumber: Int) -> ASTNode {
        // Simple while loop parsing
        let complexity = line.contains("n") ? .linear : .constant
        
        return ASTNode(
            type: .whileLoop,
            content: line,
            lineNumber: lineNumber,
            complexity: complexity,
            children: []
        )
    }
    
    private func parseIfStatement(_ line: String, lineNumber: Int) -> ASTNode {
        return ASTNode(
            type: .ifStatement,
            content: line,
            lineNumber: lineNumber,
            complexity: .constant,
            children: []
        )
    }
    
    private func parseAssignment(_ line: String, lineNumber: Int) -> ASTNode {
        return ASTNode(
            type: .assignment,
            content: line,
            lineNumber: lineNumber,
            complexity: .constant,
            children: []
        )
    }
    
    private func parseFunctionCall(_ line: String, lineNumber: Int) -> ASTNode {
        // Check for known function complexities
        if line.contains("sort") {
            return ASTNode(
                type: .functionCall,
                content: line,
                lineNumber: lineNumber,
                complexity: .linearithmic,
                children: []
            )
        } else if line.contains("binarySearch") {
            return ASTNode(
                type: .functionCall,
                content: line,
                lineNumber: lineNumber,
                complexity: .logarithmic,
                children: []
            )
        }
        
        return ASTNode(
            type: .functionCall,
            content: line,
            lineNumber: lineNumber,
            complexity: .constant,
            children: []
        )
    }
    
    /// Simulates code execution based on AST
    private func simulateExecution(ast: CodeAST, inputSize: Int) -> ExecutionTrace {
        var totalOperations = 0
        var lineExecutions: [Int: Int] = [:]
        var animationFrames: [AnimationFrame] = []
        
        for node in ast.nodes {
            let operations = simulateNode(node, inputSize: inputSize)
            totalOperations += operations
            lineExecutions[node.lineNumber] = operations
            
            // Create animation frames for visualization
            let frame = AnimationFrame(
                lineNumber: node.lineNumber,
                operations: operations,
                complexity: node.complexity,
                timestamp: Double(animationFrames.count) * 0.1
            )
            animationFrames.append(frame)
        }
        
        return ExecutionTrace(
            totalOperations: totalOperations,
            lineExecutions: lineExecutions,
            animationFrames: animationFrames,
            inputSize: inputSize
        )
    }
    
    private func simulateNode(_ node: ASTNode, inputSize: Int) -> Int {
        switch node.complexity {
        case .constant:
            return 1
        case .logarithmic:
            return Int(log2(Double(inputSize))) + 1
        case .linear:
            return inputSize
        case .linearithmic:
            return Int(Double(inputSize) * log2(Double(inputSize)))
        case .quadratic:
            return inputSize * inputSize
        case .exponential:
            // Cap exponential to prevent overflow in visualization
            return min(Int(pow(2.0, Double(inputSize))), 1000000)
        }
    }
    
    /// Determines the overall complexity from execution trace
    private func determineComplexity(executionTrace: ExecutionTrace) -> BigOComplexity {
        let n = executionTrace.inputSize
        let ops = executionTrace.totalOperations
        
        // Simple heuristic to determine complexity
        if ops <= 10 {
            return .constant
        } else if ops <= Int(log2(Double(n))) * 2 {
            return .logarithmic
        } else if ops <= n * 2 {
            return .linear
        } else if ops <= n * Int(log2(Double(n))) * 2 {
            return .linearithmic
        } else if ops <= n * n * 2 {
            return .quadratic
        } else {
            return .exponential
        }
    }
    
    /// Generates heatmap data based on execution frequency
    private func generateHeatmap(executionTrace: ExecutionTrace) -> [HeatmapData] {
        var heatmap: [HeatmapData] = []
        
        for (lineNumber, executionCount) in executionTrace.lineExecutions {
            let intensity = calculateHeatmapIntensity(executionCount: executionCount, totalOperations: executionTrace.totalOperations)
            let data = HeatmapData(
                lineNumber: lineNumber,
                intensity: intensity,
                executionCount: executionCount
            )
            heatmap.append(data)
        }
        
        return heatmap.sorted { $0.lineNumber < $1.lineNumber }
    }
    
    private func calculateHeatmapIntensity(executionCount: Int, totalOperations: Int) -> Double {
        guard totalOperations > 0 else { return 0.0 }
        return Double(executionCount) / Double(totalOperations)
    }
    
    /// Estimates execution time for visualization purposes
    private func calculateEstimatedTime(executionTrace: ExecutionTrace, inputSize: Int) -> TimeInterval {
        // Simplified estimation for visualization (not actual performance)
        let baseTimePerOperation: TimeInterval = 0.000001 // 1 microsecond per operation
        return TimeInterval(executionTrace.totalOperations) * baseTimePerOperation
    }
}

// MARK: - Data Structures

struct CodeAST {
    let nodes: [ASTNode]
}

struct ASTNode {
    let type: NodeType
    let content: String
    let lineNumber: Int
    let complexity: BigOComplexity
    let children: [ASTNode]
}

enum NodeType {
    case forLoop
    case whileLoop
    case ifStatement
    case assignment
    case functionCall
    case recursion
}

struct ExecutionTrace {
    let totalOperations: Int
    let lineExecutions: [Int: Int] // Line number -> execution count
    let animationFrames: [AnimationFrame]
    let inputSize: Int
}

struct AnimationFrame {
    let lineNumber: Int
    let operations: Int
    let complexity: BigOComplexity
    let timestamp: TimeInterval
}

struct HeatmapData {
    let lineNumber: Int
    let intensity: Double // 0.0 to 1.0
    let executionCount: Int
}

struct SimulationResult {
    let code: String
    let inputSize: Int
    let ast: CodeAST
    let executionTrace: ExecutionTrace
    let complexity: BigOComplexity
    let heatmap: [HeatmapData]
    let totalOperations: Int
    let executionTime: TimeInterval
}

// MARK: - Extensions for Analysis

extension SimulationResult {
    /// Returns a formatted description of the complexity analysis
    var complexityDescription: String {
        return "\(complexity.rawValue) - \(complexity.description)"
    }
    
    /// Returns performance metrics for different input sizes
    func performanceMetrics(for inputSizes: [Int]) -> [PerformanceMetric] {
        return inputSizes.map { size in
            let engine = ComplexitySimulationEngine.shared
            let result = engine.analyze(code: code, inputSize: size)
            
            return PerformanceMetric(
                inputSize: size,
                operations: result.totalOperations,
                complexity: result.complexity,
                estimatedTime: result.executionTime
            )
        }
    }
}

struct PerformanceMetric {
    let inputSize: Int
    let operations: Int
    let complexity: BigOComplexity
    let estimatedTime: TimeInterval
}
