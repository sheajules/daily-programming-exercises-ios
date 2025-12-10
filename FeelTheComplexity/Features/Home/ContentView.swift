import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var userProgress: [UserProgress]
    @Query private var dailyStreak: [DailyStreak]
    @State private var selectedTab: TabItem = .home
    @State private var showingWelcome = true
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(TabItem.home)
            
            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(TabItem.learn)
            
            PlaygroundView()
                .tabItem {
                    Label("Playground", systemImage: "play.circle.fill")
                }
                .tag(TabItem.playground)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(TabItem.profile)
        }
        .tint(.blue)
        .onAppear {
            setupInitialData()
        }
        .sheet(isPresented: $showingWelcome) {
            WelcomeView()
        }
    }
    
    private func setupInitialData() {
        // Create initial user progress if needed
        if userProgress.isEmpty {
            let progress = UserProgress()
            modelContext.insert(progress)
        }
        
        // Create initial daily streak if needed
        if dailyStreak.isEmpty {
            let streak = DailyStreak()
            modelContext.insert(streak)
        }
        
        // Show welcome screen for new users
        if let progress = userProgress.first, progress.totalXP == 0 {
            showingWelcome = true
        }
    }
}

enum TabItem: String, CaseIterable {
    case home = "home"
    case learn = "learn"
    case playground = "playground"
    case profile = "profile"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .learn: return "Learn"
        case .playground: return "Playground"
        case .profile: return "Profile"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .learn: return "book.fill"
        case .playground: return "play.circle.fill"
        case .profile: return "person.fill"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserProgress.self, DailyStreak.self, Lesson.self, Achievement.self], inMemory: true)
}
