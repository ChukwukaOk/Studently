import SwiftUI
import SwiftData

struct BudgetView: View {
    @Query private var budgets: [Budget]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Environment(\.modelContext) private var modelContext
    @State private var showAddBudget = false
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    private var currentMonth: Int { Calendar.current.component(.month, from: Date()) }
    private var currentYear: Int { Calendar.current.component(.year, from: Date()) }

    private var currentBudgets: [Budget] {
        budgets.filter { $0.month == currentMonth && $0.year == currentYear }
    }

    private func spentInCategory(_ category: TransactionCategory) -> Double {
        let calendar = Calendar.current
        return transactions
            .filter { !$0.isIncome && $0.category == category && calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Overview Card
                    overviewCard

                    // Category Budgets
                    if currentBudgets.isEmpty {
                        emptyBudgetView
                    } else {
                        VStack(spacing: 12) {
                            ForEach(currentBudgets) { budget in
                                BudgetCategoryCard(
                                    budget: budget,
                                    spent: spentInCategory(budget.category)
                                )
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(AppTheme.primary)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                AddBudgetView()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var overviewCard: some View {
        let totalBudget = currentBudgets.reduce(0) { $0 + $1.limit }
        let totalSpent = currentBudgets.reduce(0) { $0 + spentInCategory($1.category) }
        let remaining = totalBudget - totalSpent

        return VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Month")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(Date().formatted(.dateTime.month(.wide).year()))
                        .font(.headline)
                }
                Spacer()
            }

            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Budget")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(totalBudget))
                        .font(.title3.bold())
                }

                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(totalSpent))
                        .font(.title3.bold())
                        .foregroundStyle(AppTheme.accent)
                }

                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 1, height: 30)

                VStack(spacing: 4) {
                    Text("Left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(remaining))
                        .font(.title3.bold())
                        .foregroundStyle(remaining >= 0 ? .green : .red)
                }
            }
        }
        .cardStyle()
    }

    private var emptyBudgetView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.pie")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.primary.opacity(0.5))

            Text("No budgets set")
                .font(.headline)

            Text("Set spending limits for each category\nto stay on track")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddBudget = true
            } label: {
                Label("Create Budget", systemImage: "plus")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

// MARK: - Budget Category Card
struct BudgetCategoryCard: View {
    let budget: Budget
    let spent: Double

    private var progress: Double {
        guard budget.limit > 0 else { return 0 }
        return min(spent / budget.limit, 1.0)
    }

    private var isOverBudget: Bool { spent > budget.limit }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(budget.category.color.opacity(0.15))
                        .frame(width: 38, height: 38)

                    Image(systemName: budget.category.icon)
                        .foregroundStyle(budget.category.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(budget.category.rawValue)
                        .font(.subheadline.bold())
                    Text("\(CurrencyFormatter.format(spent)) of \(CurrencyFormatter.format(budget.limit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isOverBudget {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                } else {
                    Text("\(Int((1 - progress) * 100))%")
                        .font(.subheadline.bold())
                        .foregroundStyle(progress > 0.8 ? .orange : .green)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(budget.category.color.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(isOverBudget ? Color.red : budget.category.color)
                        .frame(width: geo.size.width * progress, height: 8)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)
        }
        .cardStyle()
    }
}

// MARK: - Add Budget View
struct AddBudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: TransactionCategory = .food
    @State private var limitAmount = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Set a Budget")
                    .font(.title2.bold())

                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(TransactionCategory.expenseCategories) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedCategory == category ? category.color : category.color.opacity(0.15))
                                            .frame(width: 48, height: 48)

                                        Image(systemName: category.icon)
                                            .foregroundStyle(selectedCategory == category ? .white : category.color)
                                    }
                                    Text(category.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(selectedCategory == category ? category.color : .secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Amount Input
                VStack(spacing: 8) {
                    Text("Monthly Limit")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(SupportedCurrency(rawValue: CurrencyFormatter.activeCurrency)?.symbol ?? "$")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $limitAmount)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 200)
                }

                Spacer()

                Button {
                    let calendar = Calendar.current
                    let budget = Budget(
                        category: selectedCategory,
                        limit: Double(limitAmount) ?? 0,
                        month: calendar.component(.month, from: Date()),
                        year: calendar.component(.year, from: Date())
                    )
                    modelContext.insert(budget)
                    try? modelContext.save()
                    HapticManager.shared.notification(.success)
                    dismiss()
                } label: {
                    Text("Set Budget")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(limitAmount.isEmpty)
                .opacity(limitAmount.isEmpty ? 0.5 : 1)
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
