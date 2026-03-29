import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @Query private var transactions: [Transaction]
    @Query private var savingsGoals: [SavingsGoal]
    @Query private var budgets: [Budget]
    @Environment(\.modelContext) private var modelContext
    @State private var showEditProfile = false
    @State private var showAddGoal = false
    @State private var showAchievements = false
    @State private var showHealthScore = false
    @State private var showInsights = false
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    private var profile: UserProfile? {
        profiles.first
    }

    private var achievementContext: AchievementContext {
        AchievementContext(transactions: transactions, budgets: budgets, savingsGoals: savingsGoals, profile: profile)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header
                    profileHeader

                    // Stats Grid
                    statsGrid

                    // Achievements Preview
                    achievementsPreview

                    // Savings Goals
                    savingsGoalsSection

                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(AppTheme.primary)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAddGoal) {
                AddSavingsGoalView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showAchievements) {
                AchievementsView()
            }
            .sheet(isPresented: $showHealthScore) {
                HealthScoreView()
            }
            .sheet(isPresented: $showInsights) {
                NavigationStack {
                    InsightsView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") { showInsights = false }
                            }
                        }
                }
            }
        }
    }

    // MARK: - Achievements Preview
    private var achievementsPreview: some View {
        let unlocked = AchievementStore.unlockedAchievements(context: achievementContext)
        let total = AchievementStore.all.count

        return Button {
            showAchievements = true
            HapticManager.shared.impact(.light)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.yellow.opacity(0.15))
                        .frame(width: 50, height: 50)
                    Image(systemName: "trophy.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Achievements")
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text("\(unlocked.count)/\(total) unlocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Mini badge icons
                HStack(spacing: -6) {
                    ForEach(unlocked.prefix(3)) { achievement in
                        ZStack {
                            Circle()
                                .fill(achievement.color)
                                .frame(width: 28, height: 28)
                            Image(systemName: achievement.icon)
                                .font(.caption2)
                                .foregroundStyle(.white)
                        }
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .cardStyle()
        }
        .buttonStyle(BounceButtonStyle())
    }

    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: 80, height: 80)

                Text(String(profile?.name.prefix(1) ?? "S").uppercased())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text(profile?.name ?? "Student")
                    .font(.title2.bold())

                if let uni = profile?.university, !uni.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "building.columns.fill")
                            .font(.caption)
                        Text(uni)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            // Streak
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(profile?.streakDays ?? 0) day streak")
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.orange.opacity(0.1))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: - Stats Grid
    private var statsGrid: some View {
        let totalTransactions = transactions.count
        let totalSaved = savingsGoals.reduce(0) { $0 + $1.currentAmount }
        let monthlySpent = transactions
            .filter { !$0.isIncome && Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            profileStat(icon: "receipt.fill", title: "Transactions", value: "\(totalTransactions)", color: AppTheme.primary)
            profileStat(icon: "banknote.fill", title: "Saved", value: CurrencyFormatter.format(totalSaved), color: .green)
            profileStat(icon: "flame.fill", title: "This Month", value: CurrencyFormatter.format(monthlySpent), color: .orange)
            profileStat(icon: "target", title: "Goals", value: "\(savingsGoals.count)", color: .purple)
        }
    }

    private func profileStat(icon: String, title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: - Savings Goals Section
    private var savingsGoalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Savings Goals")
                    .font(.headline)
                Spacer()
                Button {
                    showAddGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(AppTheme.primary)
                }
            }

            if savingsGoals.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No savings goals yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(savingsGoals) { goal in
                    SavingsGoalCard(goal: goal)
                }
            }
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            VStack(spacing: 0) {
                actionRow(icon: "chart.bar.fill", title: "Spending Insights", color: .blue) {
                    showInsights = true
                }

                Divider().padding(.leading, 44)

                actionRow(icon: "heart.text.clipboard.fill", title: "Financial Health", color: .green) {
                    showHealthScore = true
                }

                Divider().padding(.leading, 44)

                actionRow(icon: "trophy.fill", title: "Achievements", color: .yellow) {
                    showAchievements = true
                }
            }
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

        }
    }

    private func actionRow(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 28)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var university = ""
    @State private var allowance = ""
    @State private var selectedCurrency: SupportedCurrency = .cad

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        formField(title: "Name", text: $name, icon: "person.fill")
                        formField(title: "University", text: $university, icon: "building.columns.fill")
                        formField(title: "Monthly Budget", text: $allowance, icon: "dollarsign.circle.fill")
                            .keyboardType(.decimalPad)

                        // Currency Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Currency")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(SupportedCurrency.allCases) { currency in
                                        Button {
                                            withAnimation(.spring(response: 0.2)) {
                                                selectedCurrency = currency
                                            }
                                            HapticManager.shared.selection()
                                        } label: {
                                            VStack(spacing: 4) {
                                                Text(currency.flag)
                                                    .font(.title2)
                                                Text(currency.rawValue)
                                                    .font(.caption.bold())
                                                    .foregroundStyle(selectedCurrency == currency ? .white : .primary)
                                            }
                                            .frame(width: 60)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedCurrency == currency
                                                    ? AnyShapeStyle(AppTheme.primaryGradient)
                                                    : AnyShapeStyle(Color(.systemGray6))
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 20)

                    Button {
                        saveChanges()
                    } label: {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(BounceButtonStyle())
                }
                .padding()
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name = profile?.name ?? ""
                university = profile?.university ?? ""
                allowance = profile?.monthlyAllowance != nil ? String(format: "%.0f", profile!.monthlyAllowance) : ""
                selectedCurrency = SupportedCurrency(rawValue: profile?.currency ?? "CAD") ?? .cad
            }
        }
    }

    private func saveChanges() {
        if let profile {
            profile.name = name
            profile.university = university
            profile.monthlyAllowance = Double(allowance) ?? 0
            profile.currency = selectedCurrency.rawValue
            CurrencyFormatter.activeCurrency = selectedCurrency.rawValue
            try? modelContext.save()
        }
        HapticManager.shared.notification(.success)
        dismiss()
    }

    private func formField(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(AppTheme.primary)
                    .frame(width: 20)
                TextField(title, text: text)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Add Savings Goal View
struct AddSavingsGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var selectedIcon = "star.fill"

    private let icons = ["star.fill", "airplane", "car.fill", "laptopcomputer", "iphone", "headphones", "gamecontroller.fill", "book.fill", "house.fill", "gift.fill"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("New Savings Goal")
                    .font(.title2.bold())

                // Icon Selection
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(selectedIcon == icon ? AppTheme.primary : Color(.systemGray5))
                                    .frame(width: 48, height: 48)

                                Image(systemName: icon)
                                    .foregroundStyle(selectedIcon == icon ? .white : .secondary)
                            }
                        }
                    }
                }

                VStack(spacing: 16) {
                    TextField("Goal name (e.g., New Laptop)", text: $title)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    HStack {
                        Text(SupportedCurrency(rawValue: CurrencyFormatter.activeCurrency)?.symbol ?? "$")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        TextField("Target amount", text: $targetAmount)
                            .keyboardType(.decimalPad)
                            .font(.title2.bold())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Spacer()

                Button {
                    let goal = SavingsGoal(
                        title: title,
                        targetAmount: Double(targetAmount) ?? 0,
                        icon: selectedIcon
                    )
                    modelContext.insert(goal)
                    try? modelContext.save()
                    HapticManager.shared.notification(.success)
                    dismiss()
                } label: {
                    Text("Create Goal")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(title.isEmpty || targetAmount.isEmpty)
                .opacity((title.isEmpty || targetAmount.isEmpty) ? 0.5 : 1)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
