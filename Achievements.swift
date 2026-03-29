import Foundation
import SwiftUI

// MARK: - Achievement Definition
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requirement: (AchievementContext) -> Bool
}

struct AchievementContext {
    let transactions: [Transaction]
    let budgets: [Budget]
    let savingsGoals: [SavingsGoal]
    let profile: UserProfile?
}

// MARK: - All Achievements
struct AchievementStore {
    static let all: [Achievement] = [
        Achievement(
            id: "first_expense",
            title: "First Step",
            description: "Log your first expense",
            icon: "shoe.fill",
            color: .blue
        ) { ctx in !ctx.transactions.isEmpty },

        Achievement(
            id: "budget_setter",
            title: "Budget Boss",
            description: "Create your first budget",
            icon: "chart.pie.fill",
            color: .purple
        ) { ctx in !ctx.budgets.isEmpty },

        Achievement(
            id: "savings_starter",
            title: "Future Investor",
            description: "Create a savings goal",
            icon: "star.fill",
            color: .yellow
        ) { ctx in !ctx.savingsGoals.isEmpty },

        Achievement(
            id: "ten_transactions",
            title: "Getting Serious",
            description: "Log 10 transactions",
            icon: "10.circle.fill",
            color: .green
        ) { ctx in ctx.transactions.count >= 10 },

        Achievement(
            id: "fifty_transactions",
            title: "Finance Pro",
            description: "Log 50 transactions",
            icon: "50.circle.fill",
            color: .orange
        ) { ctx in ctx.transactions.count >= 50 },

        Achievement(
            id: "week_streak",
            title: "Week Warrior",
            description: "Track expenses for 7 days straight",
            icon: "flame.fill",
            color: .red
        ) { ctx in
            let calendar = Calendar.current
            let sortedDates = Set(ctx.transactions.map { calendar.startOfDay(for: $0.date) }).sorted()
            guard sortedDates.count >= 7 else { return false }
            var streak = 1
            for i in 1..<sortedDates.count {
                if calendar.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day == 1 {
                    streak += 1
                    if streak >= 7 { return true }
                } else {
                    streak = 1
                }
            }
            return false
        },

        Achievement(
            id: "under_budget",
            title: "Money Master",
            description: "Stay under budget for all categories in a month",
            icon: "crown.fill",
            color: Color(hex: "FFD700")
        ) { ctx in
            guard !ctx.budgets.isEmpty else { return false }
            let calendar = Calendar.current
            return ctx.budgets.allSatisfy { budget in
                let spent = ctx.transactions
                    .filter { !$0.isIncome && $0.category == budget.category && calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
                    .reduce(0) { $0 + $1.amount }
                return spent <= budget.limit
            }
        },

        Achievement(
            id: "savings_50",
            title: "Halfway There",
            description: "Reach 50% of a savings goal",
            icon: "flag.checkered",
            color: .teal
        ) { ctx in ctx.savingsGoals.contains { $0.progress >= 0.5 } },

        Achievement(
            id: "savings_complete",
            title: "Goal Crusher",
            description: "Complete a savings goal",
            icon: "trophy.fill",
            color: Color(hex: "FFD700")
        ) { ctx in ctx.savingsGoals.contains { $0.progress >= 1.0 } },

        Achievement(
            id: "five_budgets",
            title: "Budget Architect",
            description: "Set budgets for 5 categories",
            icon: "building.columns.fill",
            color: .indigo
        ) { ctx in
            let calendar = Calendar.current
            let month = calendar.component(.month, from: Date())
            let year = calendar.component(.year, from: Date())
            return ctx.budgets.filter { $0.month == month && $0.year == year }.count >= 5
        },

        Achievement(
            id: "income_tracked",
            title: "Money Maker",
            description: "Log your first income",
            icon: "dollarsign.arrow.circlepath",
            color: .green
        ) { ctx in ctx.transactions.contains { $0.isIncome } },

        Achievement(
            id: "diverse_spender",
            title: "Well Rounded",
            description: "Log expenses in 5+ categories",
            icon: "circle.grid.cross.fill",
            color: .mint
        ) { ctx in
            Set(ctx.transactions.filter { !$0.isIncome }.map { $0.categoryRaw }).count >= 5
        },
    ]

    static func unlockedAchievements(context: AchievementContext) -> [Achievement] {
        all.filter { $0.requirement(context) }
    }

    static func lockedAchievements(context: AchievementContext) -> [Achievement] {
        all.filter { !$0.requirement(context) }
    }
}
