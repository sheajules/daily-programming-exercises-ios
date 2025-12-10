import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let pages = [
        WelcomePage(
            title: "Feel the Complexity",
            description: "Learn Big-O notation through interactive visualizations and hands-on coding experiences.",
            icon: "brain.head.profile",
            color: .blue
        ),
        WelcomePage(
            title: "Learn by Doing",
            description: "Write code, see it run, and understand complexity through visual animations.",
            icon: "play.circle.fill",
            color: .green
        ),
        WelcomePage(
            title: "Build Intuition",
            description: "Develop a deep understanding of how algorithms scale with input size.",
            icon: "chart.line.uptrend.xyaxis",
            color: .orange
        ),
        WelcomePage(
            title: "Stay Consistent",
            description: "Daily practice with streaks and achievements to master complexity analysis.",
            icon: "flame.fill",
            color: .red
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentPage ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 20)
            
            // Content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    WelcomePageContent(page: page) {
                        if index < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.x < -50 && currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else if value.translation.x > 50 && currentPage > 0 {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                    }
            )
            
            // Navigation Buttons
            HStack {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
                
                Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
}

struct WelcomePage {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct WelcomePageContent: View {
    let page: WelcomePage
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.6), value: page.icon)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Illustration placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(page.color.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Text("📱")
                            .font(.system(size: 48))
                        Text("Interactive Learning")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(page.color)
                    }
                )
                .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
}
