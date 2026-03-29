import Foundation
import SwiftData
import SwiftUI

// MARK: - Transaction Category
enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case food = "Food & Drinks"
    case transport = "Transport"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case bills = "Bills & Utilities"
    case education = "Education"
    case health = "Health"
    case subscriptions = "Subscriptions"
    case income = "Income"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .shopping: return "bag.fill"
        case .bills: return "bolt.fill"
        case .education: return "book.fill"
        case .health: return "heart.fill"
        case .subscriptions: return "repeat"
        case .income: return "banknote.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: return .orange
        case .transport: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .bills: return .yellow
        case .education: return .teal
        case .health: return .red
        case .subscriptions: return .indigo
        case .income: return .green
        case .other: return .gray
        }
    }

    static var expenseCategories: [TransactionCategory] {
        allCases.filter { $0 != .income }
    }
}

// MARK: - Transaction Model
@Model
final class Transaction {
    var id: UUID
    var title: String
    var amount: Double
    var categoryRaw: String
    var date: Date
    var note: String
    var isIncome: Bool

    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(title: String, amount: Double, category: TransactionCategory, date: Date = .now, note: String = "", isIncome: Bool = false) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.categoryRaw = category.rawValue
        self.date = date
        self.note = note
        self.isIncome = isIncome
    }
}

// MARK: - Budget Model
@Model
final class Budget {
    var id: UUID
    var categoryRaw: String
    var limit: Double
    var month: Int
    var year: Int

    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    init(category: TransactionCategory, limit: Double, month: Int, year: Int) {
        self.id = UUID()
        self.categoryRaw = category.rawValue
        self.limit = limit
        self.month = month
        self.year = year
    }
}

// MARK: - Savings Goal Model
@Model
final class SavingsGoal {
    var id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var icon: String
    var deadline: Date?
    var createdAt: Date

    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }

    init(title: String, targetAmount: Double, currentAmount: Double = 0, icon: String = "star.fill", deadline: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.icon = icon
        self.deadline = deadline
        self.createdAt = .now
    }
}

// MARK: - User Profile
@Model
final class UserProfile {
    var id: UUID
    var name: String
    var university: String
    var monthlyAllowance: Double
    var currency: String
    var streakDays: Int
    var joinedDate: Date

    init(name: String = "", university: String = "", monthlyAllowance: Double = 0, currency: String = "CAD") {
        self.id = UUID()
        self.name = name
        self.university = university
        self.monthlyAllowance = monthlyAllowance
        self.currency = currency
        self.streakDays = 0
        self.joinedDate = .now
    }
}
