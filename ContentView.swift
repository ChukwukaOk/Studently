import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddTransaction = false
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding = false

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)

                BudgetView()
                    .tag(1)

                Color.clear
                    .tag(2)

                LearnView()
                    .tag(3)

                ProfileView()
                    .tag(4)
            }
            .tint(AppTheme.primary)

            CustomTabBar(selectedTab: $selectedTab, showAddTransaction: $showAddTransaction)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView()
        }
        .onAppear {
            if profiles.isEmpty {
                showOnboarding = true
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var showAddTransaction: Bool

    var body: some View {
        HStack {
            tabButton(icon: "house.fill", label: "Home", tag: 0)
            tabButton(icon: "chart.pie.fill", label: "Budget", tag: 1)

            Button {
                showAddTransaction = true
                HapticManager.shared.impact(.medium)
            } label: {
                ZStack {
                    Circle()
                        .fill(AppTheme.primaryGradient)
                        .frame(width: 56, height: 56)
                        .shadow(color: AppTheme.primary.opacity(0.4), radius: 8, y: 4)

                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -16)

            tabButton(icon: "book.fill", label: "Learn", tag: 3)
            tabButton(icon: "person.fill", label: "Profile", tag: 4)
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        )
    }

    @ViewBuilder
    private func tabButton(icon: String, label: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedTab = tag
            }
            HapticManager.shared.selection()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                    .symbolEffect(.bounce, value: selectedTab == tag)
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(selectedTab == tag ? AppTheme.primary : .gray)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var name = ""
    @State private var university = ""
    @State private var monthlyAllowance = ""
    @State private var selectedCurrency: SupportedCurrency = .cad
    @State private var animateIcon = false
    @State private var showCelebration = false

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("graduationcap.fill", "Welcome to\nStudently", "Your personal finance companion\nbuilt for students"),
        ("chart.pie.fill", "Track & Budget", "Log expenses, set budgets,\nand see where your money goes"),
        ("trophy.fill", "Earn Rewards", "Build streaks, unlock achievements,\nand level up your money skills"),
    ]

    var body: some View {
        ZStack {
            if showCelebration {
                AccountCreatedCelebration {
                    dismiss()
                }
                .transition(.opacity)
            } else {
                onboardingContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: showCelebration)
    }

    private var onboardingContent: some View {
        ZStack {
            AppTheme.primaryGradient
                .ignoresSafeArea()
                .overlay(
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 300, height: 300)
                        .offset(x: 100, y: -200)
                )
                .overlay(
                    Circle()
                        .fill(.white.opacity(0.05))
                        .frame(width: 200, height: 200)
                        .offset(x: -120, y: 250)
                )

            VStack(spacing: 0) {
                if currentPage < pages.count {
                    featurePage
                } else {
                    setupPage
                }
            }
        }
    }

    private var featurePage: some View {
        let page = pages[currentPage]

        return VStack(spacing: 32) {
            Spacer()

            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .scaleEffect(animateIcon ? 1 : 0.5)
                .opacity(animateIcon ? 1 : 0)
                .onAppear {
                    animateIcon = false
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                        animateIcon = true
                    }
                }

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(.white.opacity(i == currentPage ? 1 : 0.3))
                        .frame(width: i == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.3), value: currentPage)
                }
            }
            .padding(.bottom, 20)

            Button {
                withAnimation(.spring(response: 0.4)) {
                    currentPage += 1
                }
                HapticManager.shared.impact(.light)
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Set Up Profile")
                    .font(.headline)
                    .foregroundStyle(AppTheme.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(BounceButtonStyle())
            .padding(.horizontal, 30)

            if currentPage < pages.count - 1 {
                Button {
                    withAnimation { currentPage = pages.count }
                } label: {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 8)
            }
        }
        .padding(.bottom, 40)
    }

    private var setupPage: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 40)

                VStack(spacing: 8) {
                    Text("Let's set you up")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                    Text("This helps us personalize your experience")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }

                VStack(spacing: 16) {
                    onboardingField(icon: "person.fill", placeholder: "Your Name", text: $name)
                    onboardingField(icon: "building.columns.fill", placeholder: "University", text: $university)
                    onboardingField(icon: "dollarsign.circle.fill", placeholder: "Monthly Budget", text: $monthlyAllowance)
                        .keyboardType(.decimalPad)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currency")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.leading, 4)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(SupportedCurrency.allCases) { currency in
                                    Button {
                                        withAnimation(.spring(response: 0.2)) {
                                            selectedCurrency = currency
                                        }
                                        HapticManager.shared.selection()
                                    } label: {
                                        VStack(spacing: 6) {
                                            Text(currency.flag)
                                                .font(.title)
                                            Text(currency.rawValue)
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                        .frame(width: 60)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedCurrency == currency
                                                ? .white.opacity(0.3)
                                                : .white.opacity(0.1)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(.white.opacity(selectedCurrency == currency ? 0.8 : 0), lineWidth: 2)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 30)

                Spacer(minLength: 30)

                Button {
                    createAccount()
                } label: {
                    Text("Start My Journey")
                        .font(.headline)
                        .foregroundStyle(AppTheme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(BounceButtonStyle())
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.6 : 1)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }

    private func createAccount() {
        let profile = UserProfile(
            name: name,
            university: university,
            monthlyAllowance: Double(monthlyAllowance) ?? 0,
            currency: selectedCurrency.rawValue
        )
        modelContext.insert(profile)
        try? modelContext.save()
        CurrencyFormatter.activeCurrency = selectedCurrency.rawValue
        HapticManager.shared.notification(.success)

        withAnimation {
            showCelebration = true
        }
    }

    private func onboardingField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 24)

            TextField(placeholder, text: text)
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding()
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
