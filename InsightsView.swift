import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @State private var selectedTimeframe: Timeframe = .month
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case semester = "Semester"
    }

    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        return transactions.filter { t in
            !t.isIncome && {
                switch selectedTimeframe {
                case .week:
                    return calendar.isDate(t.date, equalTo: now, toGranularity: .weekOfYear)
                case .month:
                    return calendar.isDate(t.date, equalTo: now, toGranularity: .month)
                case .semester:
                    let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now)!
                    return t.date >= sixMonthsAgo
                }
            }()
        }
    }

    private var categoryBreakdown: [(category: TransactionCategory, total: Double)] {
        var dict: [TransactionCategory: Double] = [:]
        for t in filteredTransactions {
            dict[t.category, default: 0] += t.amount
        }
        return dict.map { (category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }
    }

    private var totalSpent: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    private var dailySpending: [(date: Date, amount: Double)] {
        let calendar = Calendar.current
        var dict: [Date: Double] = [:]
        for t in filteredTransactions {
            let day = calendar.startOfDay(for: t.date)
            dict[day, default: 0] += t.amount
        }
        return dict.map { (date: $0.key, amount: $0.value) }
            .sorted { $0.date < $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Timeframe Picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { tf in
                            Text(tf.rawValue).tag(tf)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if filteredTransactions.isEmpty {
                        emptyInsightsView
                    } else {
                        // Spending Chart
                        spendingChart

                        // Category Breakdown
                        categoryBreakdownSection

                        // Smart Tips
                        smartTipsSection
                    }
                }
                .padding(.vertical)
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Insights")
        }
    }

    // MARK: - Spending Chart
    private var spendingChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending Trend")
                .font(.headline)
                .padding(.horizontal)

            Chart(dailySpending, id: \.date) { item in
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(AppTheme.primaryGradient)
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(AppTheme.primary)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Category Breakdown
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Where Your Money Goes")
                .font(.headline)

            // Donut Chart
            Chart(categoryBreakdown, id: \.category) { item in
                SectorMark(
                    angle: .value("Amount", item.total),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(item.category.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .overlay {
                VStack(spacing: 2) {
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(CurrencyFormatter.format(totalSpent))
                        .font(.title3.bold())
                }
            }

            // Legend
            VStack(spacing: 8) {
                ForEach(categoryBreakdown, id: \.category) { item in
                    HStack {
                        Circle()
                            .fill(item.category.color)
                            .frame(width: 10, height: 10)

                        Text(item.category.rawValue)
                            .font(.subheadline)

                        Spacer()

                        Text(CurrencyFormatter.format(item.total))
                            .font(.subheadline.bold())

                        Text("\(Int((item.total / totalSpent) * 100))%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 35, alignment: .trailing)
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    // MARK: - Smart Tips
    private var smartTipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                Text("Smart Tips")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                ForEach(generateTips(), id: \.self) { tip in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "sparkle")
                            .font(.caption)
                            .foregroundStyle(AppTheme.primary)
                            .padding(.top, 2)
                        Text(tip)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .cardStyle()
        .padding(.horizontal)
    }

    private func generateTips() -> [String] {
        var tips: [String] = []

        if let topCategory = categoryBreakdown.first {
            tips.append("Your biggest expense is \(topCategory.category.rawValue) at \(CurrencyFormatter.format(topCategory.total)). Consider setting a budget for this category.")
        }

        let avgDaily = totalSpent / max(Double(dailySpending.count), 1)
        tips.append("You're spending an average of \(CurrencyFormatter.format(avgDaily)) per day.")

        if categoryBreakdown.contains(where: { $0.category == .subscriptions }) {
            tips.append("Review your subscriptions regularly — unused subscriptions are a common money leak for students!")
        }

        if categoryBreakdown.contains(where: { $0.category == .food && $0.total > totalSpent * 0.4 }) {
            tips.append("Food makes up over 40% of your spending. Try meal prepping to save money!")
        }

        return tips
    }

    private var emptyInsightsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 50))
                .foregroundStyle(AppTheme.primary.opacity(0.5))

            Text("Not enough data yet")
                .font(.headline)

            Text("Start tracking your expenses to see\npersonalized insights and tips")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }
}
