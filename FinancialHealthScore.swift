import Foundation
import SwiftUI

// MARK: - Financial Health Score Engine
struct FinancialHealthScore {
    let transactions: [Transaction]
    let budgets: [Budget]
    let savingsGoals: [SavingsGoal]
    let profile: UserProfile?

    // Overall score out of 100
    var overallScore: Int {
        let components = [
            budgetAdherenceScore,
            savingsScore,
            consistencyScore,
            diversityScore,
            trackingScore
        ]
        let total = components.reduce(0, +)
        return min(max(total / components.count, 0), 100)
    }

    var grade: String {
        switch overallScore {
        case 90...100: return "A+"
        case 80..<90: return "A"
        case 70..<80: return "B"
        case 60..<70: return "C"
        case 50..<60: return "D"
        default: return "F"
        }
    }

    var gradeColor: Color {
        switch overallScore {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    var gradientForScore: LinearGradient {
        switch overallScore {
        case 80...100: return AppTheme.successGradient
        case 60..<80: return LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return AppTheme.accentGradient
        }
    }

    // Score components (each 0-100)

    // Are you staying within budget?
    var budgetAdherenceScore: Int {
        guard !budgets.isEmpty else { return 50 }
        let calendar = Calendar.current
        var scores: [Double] = []

        for budget in budgets {
            let spent = transactions
                .filter { !$0.isIncome && $0.category == budget.category && calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                .reduce(0) { $0 + $1.amount }

            let ratio = budget.limit > 0 ? spent / budget.limit : 0
            if ratio <= 0.8 { scores.append(100) }
            else if ratio <= 1.0 { scores.append(70) }
            else { scores.append(max(0, 40 - (ratio - 1) * 40)) }
        }

        return Int(scores.reduce(0, +) / Double(scores.count))
    }

    // Are you saving money?
    var savingsScore: Int {
        guard !savingsGoals.isEmpty else { return 30 }
        let avgProgress = savingsGoals.reduce(0.0) { $0 + $1.progress } / Double(savingsGoals.count)
        return Int(avgProgress * 100)
    }

    // Are you tracking regularly?
    var consistencyScore: Int {
        let calendar = Calendar.current
        let last30Days = calendar.date(byAdding: .day, value: -30, to: Date())!
        let recentTransactions = transactions.filter { $0.date >= last30Days }

        let uniqueDays = Set(recentTransactions.map { calendar.startOfDay(for: $0.date) }).count
        return min(Int(Double(uniqueDays) / 15.0 * 100), 100)
    }

    // Are expenses spread across categories (not all one thing)?
    var diversityScore: Int {
        let calendar = Calendar.current
        let monthlyExpenses = transactions.filter { !$0.isIncome && calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        let categories = Set(monthlyExpenses.map { $0.categoryRaw })
        return min(Int(Double(categories.count) / 4.0 * 100), 100)
    }

    // Basic tracking engagement
    var trackingScore: Int {
        let count = transactions.count
        if count >= 30 { return 100 }
        if count >= 15 { return 80 }
        if count >= 5 { return 60 }
        if count >= 1 { return 40 }
        return 10
    }

    // Breakdown items for display
    var breakdown: [(title: String, score: Int, icon: String, tip: String)] {
        [
            (
                title: "Budget Discipline",
                score: budgetAdherenceScore,
                icon: "chart.pie.fill",
                tip: budgetAdherenceScore < 70 ? "Try reducing spending in your top category" : "Great job staying within your budgets!"
            ),
            (
                title: "Savings Progress",
                score: savingsScore,
                icon: "banknote.fill",
                tip: savingsScore < 50 ? "Set up a savings goal and add to it weekly" : "You're building great savings habits!"
            ),
            (
                title: "Tracking Consistency",
                score: consistencyScore,
                icon: "calendar.badge.checkmark",
                tip: consistencyScore < 70 ? "Log expenses daily for better awareness" : "Consistent tracking is key — keep it up!"
            ),
            (
                title: "Spending Diversity",
                score: diversityScore,
                icon: "square.grid.3x3.fill",
                tip: diversityScore < 50 ? "Categorize your expenses to see the full picture" : "Good spread of spending categories"
            ),
            (
                title: "Engagement",
                score: trackingScore,
                icon: "flame.fill",
                tip: trackingScore < 60 ? "The more you track, the better your score!" : "Power user! Keep tracking everything"
            )
        ]
    }
}
