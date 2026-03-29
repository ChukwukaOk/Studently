import SwiftUI
import SwiftData

@main
struct StudentlyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            Transaction.self,
            Budget.self,
            SavingsGoal.self,
            UserProfile.self
        ])
    }
}

// MARK: - Root View with Splash
struct RootView: View {
    @State private var showSplash = true
    @Query private var profiles: [UserProfile]

    var body: some View {
        ZStack {
            ContentView()
                .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashScreen()
                    .transition(.opacity)
            }
        }
        .onAppear {
            if let profile = profiles.first {
                CurrencyFormatter.activeCurrency = profile.currency
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}
