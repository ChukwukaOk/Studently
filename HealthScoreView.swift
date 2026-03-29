import SwiftUI
import SwiftData

struct HealthScoreView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var budgets: [Budget]
    @Query private var savingsGoals: [SavingsGoal]
    @Query private var profiles: [UserProfile]
    @Environment(\.dismiss) private var dismiss
    @State private var animateScore = false

    private var score: FinancialHealthScore {
        FinancialHealthScore(
            transactions: transactions,
            budgets: budgets,
            savingsGoals: savingsGoals,
            profile: profiles.first
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Score Ring
                    scoreCard

                    // Breakdown
                    breakdownSection

                    // Personalized Advice
                    adviceSection
                }
                .padding()
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Financial Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Score Card
    private var scoreCard: some View {
        VStack(spacing: 20) {
            ZStack {
                ProgressRing(
                    progress: animateScore ? Double(score.overallScore) / 100.0 : 0,
                    lineWidth: 16,
                    gradient: score.gradientForScore,
                    size: 180
                )

                VStack(spacing: 4) {
                    Text("\(animateScore ? score.overallScore : 0)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .contentTransition(.numericText(value: Double(score.overallScore)))

                    Text(score.grade)
                        .font(.title3.bold())
                        .foregroundStyle(score.gradeColor)

                    Text("Financial Health")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(scoreMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateScore = true
            }
        }
    }

    private var scoreMessage: String {
        switch score.overallScore {
        case 80...100: return "Excellent! You're managing your finances like a pro."
        case 60..<80: return "Good progress! A few improvements and you'll be in great shape."
        case 40..<60: return "You're getting there. Focus on the areas below to improve."
        default: return "Let's work on building better financial habits together!"
        }
    }

    // MARK: - Breakdown
    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Score Breakdown")
                .font(.headline)

            ForEach(Array(score.breakdown.enumerated()), id: \.element.title) { index, item in
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: item.icon)
                            .font(.body)
                            .foregroundStyle(colorForScore(item.score))
                            .frame(width: 24)

                        Text(item.title)
                            .font(.subheadline)

                        Spacer()

                        Text("\(item.score)")
                            .font(.subheadline.bold())
                            .foregroundStyle(colorForScore(item.score))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 6)

                            Capsule()
                                .fill(colorForScore(item.score))
                                .frame(width: geo.size.width * Double(item.score) / 100.0, height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(item.tip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .staggered(index: index)

                if index < score.breakdown.count - 1 {
                    Divider()
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Advice
    private var adviceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.max.fill")
                    .foregroundStyle(.yellow)
                Text("Your Next Steps")
                    .font(.headline)
            }

            let weakest = score.breakdown.min(by: { $0.score < $1.score })
            if let weakest = weakest {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Focus Area: \(weakest.title)")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppTheme.primary)

                    Text(detailedAdvice(for: weakest.title))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                }
            }
        }
        .cardStyle()
    }

    private func colorForScore(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    private func detailedAdvice(for area: String) -> String {
        switch area {
        case "Budget Discipline":
            return "Set realistic budget limits for your top spending categories. Start with your biggest expense and reduce it by 10% this month."
        case "Savings Progress":
            return "Create a savings goal for something you want. Even saving $5/day gets you to $150/month. Try the 'round-up' technique — round up every purchase to the nearest dollar and save the difference."
        case "Tracking Consistency":
            return "Make it a habit to log expenses right after each purchase. Set a daily reminder for 9 PM to review and log any you missed."
        case "Spending Diversity":
            return "Make sure you're categorizing all your expenses. This helps you see the full picture of where your money goes."
        case "Engagement":
            return "Keep using Studently daily! The more you track, the better insights you'll get, and the higher your score will climb."
        default:
            return "Keep tracking your finances to see improvement!"
        }
    }
}
