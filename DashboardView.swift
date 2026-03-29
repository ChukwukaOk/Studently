import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var profiles: [UserProfile]
    @Query private var savingsGoals: [SavingsGoal]
    @Query private var budgets: [Budget]
    @State private var showAllTransactions = false
    @State private var showHealthScore = false
    @State private var showAchievements = false
    @State private var showBillSplit = false
    @State private var animateCards = false
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    private var profile: UserProfile? {
        profiles.first
    }

    private var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
    }

    private var totalSpent: Double {
        currentMonthTransactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    private var totalIncome: Double {
        currentMonthTransactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    private var balance: Double {
        (profile?.monthlyAllowance ?? 0) + totalIncome - totalSpent
    }

    private var healthScore: FinancialHealthScore {
        FinancialHealthScore(
            transactions: transactions,
            budgets: budgets,
            savingsGoals: savingsGoals,
            profile: profile
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Balance Card
                    balanceCard
                        .offset(y: animateCards ? 0 : 20)
                        .opacity(animateCards ? 1 : 0)

                    // Quick Stats
                    quickStatsRow
                        .offset(y: animateCards ? 0 : 20)
                        .opacity(animateCards ? 1 : 0)

                    // Financial Health Score Mini
                    healthScoreMini
                        .staggered(index: 2)

                    // Quick Actions
                    quickActions
                        .staggered(index: 3)

                    // Savings Goals
                    if !savingsGoals.isEmpty {
                        savingsSection
                    }

                    // Recent Transactions
                    recentTransactionsSection
                }
                .padding()
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Hey, \(profile?.name.components(separatedBy: " ").first ?? "there")!")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAllTransactions) {
                AllTransactionsView()
            }
            .sheet(isPresented: $showHealthScore) {
                HealthScoreView()
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showBillSplit) {
                BillSplitView()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                animateCards = true
            }
        }
    }

    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 16) {
            Text("Monthly Balance")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            Text(CurrencyFormatter.format(balance))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText(value: balance))

            // Budget Progress
            let budgetTotal = profile?.monthlyAllowance ?? 0
            if budgetTotal > 0 {
                VStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.white.opacity(0.2))
                                .frame(height: 8)

                            Capsule()
                                .fill(.white)
                                .frame(width: min(CGFloat(totalSpent / budgetTotal) * geo.size.width, geo.size.width), height: 8)
                                .animation(.easeInOut(duration: 0.8), value: totalSpent)
                        }
                    }
                    .frame(height: 8)

                    HStack {
                        Text("\(CurrencyFormatter.format(totalSpent)) spent")
                        Spacer()
                        Text("\(CurrencyFormatter.format(budgetTotal)) budget")
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.primary.opacity(0.3), radius: 15, y: 8)
    }

    // MARK: - Quick Stats
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Income",
                amount: totalIncome,
                icon: "arrow.down.circle.fill",
                color: .green
            )

            StatCard(
                title: "Spent",
                amount: totalSpent,
                icon: "arrow.up.circle.fill",
                color: AppTheme.accent
            )
        }
    }

    // MARK: - Health Score Mini Card
    private var healthScoreMini: some View {
        Button {
            showHealthScore = true
            HapticManager.shared.impact(.light)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    ProgressRing(
                        progress: Double(healthScore.overallScore) / 100.0,
                        lineWidth: 6,
                        gradient: healthScore.gradientForScore,
                        size: 56
                    )

                    Text("\(healthScore.overallScore)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Financial Health Score")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("Tap to see your detailed breakdown")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .cardStyle()
        }
        .buttonStyle(BounceButtonStyle())
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            HStack(spacing: 12) {
                quickActionButton(icon: "scissors", title: "Split Bill", color: .orange) {
                    showBillSplit = true
                }
                quickActionButton(icon: "trophy.fill", title: "Badges", color: .yellow) {
                    showAchievements = true
                }
                quickActionButton(icon: "heart.text.clipboard.fill", title: "Health", color: .green) {
                    showHealthScore = true
                }
            }
        }
    }

    private func quickActionButton(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button {
            action()
            HapticManager.shared.impact(.light)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.12))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .cardStyle()
        }
        .buttonStyle(BounceButtonStyle())
    }

    // MARK: - Savings Section
    private var savingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Savings Goals")
                .font(.headline)

            ForEach(savingsGoals) { goal in
                SavingsGoalCard(goal: goal)
            }
        }
    }

    // MARK: - Recent Transactions
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                Spacer()
                if !transactions.isEmpty {
                    Button("See All") {
                        showAllTransactions = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primary)
                }
            }

            if transactions.isEmpty {
                emptyTransactionsView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(transactions.prefix(5).enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                            .staggered(index: index + 4)
                    }
                }
            }
        }
    }

    private var emptyTransactionsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "receipt")
                .font(.system(size: 40))
                .foregroundStyle(.gray.opacity(0.5))
            Text("No transactions yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Tap the + button to add your first expense")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .cardStyle()
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(CurrencyFormatter.format(amount))
                .font(.title3.bold())
                .contentTransition(.numericText(value: amount))
        }
        .cardStyle()
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Savings Goal Card
struct SavingsGoalCard: View {
    let goal: SavingsGoal
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: goal.icon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.subheadline.bold())
                    Text("\(CurrencyFormatter.format(goal.currentAmount)) of \(CurrencyFormatter.format(goal.targetAmount))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(goal.progress * 100))%")
                    .font(.headline)
                    .foregroundStyle(AppTheme.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.secondary.opacity(0.2))
                        .frame(height: 8)

                    Capsule()
                        .fill(AppTheme.successGradient)
                        .frame(width: geo.size.width * goal.progress, height: 8)
                        .animation(.easeInOut(duration: 0.8), value: goal.progress)
                }
            }
            .frame(height: 8)
        }
        .cardStyle()
    }
}

// MARK: - All Transactions View
struct AllTransactionsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(transactions) { transaction in
                    TransactionRow(transaction: transaction)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteTransactions)
            }
            .listStyle(.plain)
            .navigationTitle("All Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(transactions[index])
        }
        try? modelContext.save()
    }
}
