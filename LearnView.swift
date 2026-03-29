import SwiftUI

// MARK: - Financial Literacy Content
struct LearnView: View {
    @State private var selectedTopic: LearnTopic?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Featured
                    featuredCard

                    // Topics Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Learn the Basics")
                            .font(.headline)
                            .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(Array(LearnTopic.allTopics.enumerated()), id: \.element.id) { index, topic in
                                Button {
                                    selectedTopic = topic
                                    HapticManager.shared.impact(.light)
                                } label: {
                                    TopicCard(topic: topic)
                                        .staggered(index: index)
                                }
                                .buttonStyle(BounceButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Quick Quiz
                    quizTeaser
                }
                .padding(.vertical)
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Learn")
            .sheet(item: $selectedTopic) { topic in
                TopicDetailView(topic: topic)
            }
        }
    }

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("FEATURED")
                        .font(.caption.bold())
                        .foregroundStyle(.white.opacity(0.7))

                    Text("Student's Guide\nto Budgeting")
                        .font(.title2.bold())
                        .foregroundStyle(.white)

                    Text("5 min read")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "graduationcap.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(24)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var quizTeaser: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.primary)

            Text("Test Your Knowledge")
                .font(.headline)

            Text("Take a quick quiz to see how much\nyou know about personal finance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            NavigationLink {
                QuizView()
            } label: {
                Text("Start Quiz")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppTheme.primaryGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(BounceButtonStyle())
        }
        .cardStyle()
        .padding(.horizontal)
    }
}

// MARK: - Topic Card
struct TopicCard: View {
    let topic: LearnTopic

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(topic.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: topic.icon)
                    .font(.title3)
                    .foregroundStyle(topic.color)
            }

            Text(topic.title)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(topic.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

// MARK: - Learn Topics Data
struct LearnTopic: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let content: [LessonSection]

    static let allTopics: [LearnTopic] = [
        LearnTopic(
            title: "Budgeting 101",
            subtitle: "Master the basics",
            icon: "chart.pie.fill",
            color: .purple,
            content: [
                LessonSection(heading: "What is a Budget?", body: "A budget is a plan for how you'll spend your money each month. It helps you make sure you have enough for the things you need and the things you want, while also saving for the future."),
                LessonSection(heading: "The 50/30/20 Rule", body: "A popular budgeting framework:\n\n• 50% for needs (rent, food, bills)\n• 30% for wants (entertainment, dining out)\n• 20% for savings and debt repayment\n\nAs a student, your split might look different — and that's okay! The key is having a plan."),
                LessonSection(heading: "Tips for Students", body: "• Track every expense, even small ones — they add up!\n• Use your student discounts everywhere\n• Cook meals instead of eating out\n• Buy used textbooks or use the library\n• Set up automatic transfers to savings")
            ]
        ),
        LearnTopic(
            title: "Saving Strategies",
            subtitle: "Build your safety net",
            icon: "banknote.fill",
            color: .green,
            content: [
                LessonSection(heading: "Why Save?", body: "An emergency fund protects you from unexpected expenses like car repairs, medical bills, or last-minute travel. Aim for at least $500-$1000 as a student."),
                LessonSection(heading: "Pay Yourself First", body: "Before spending on anything else, put a set amount into savings. Even $25/week adds up to $1,300/year!"),
                LessonSection(heading: "The Latte Factor", body: "Small daily expenses seem harmless, but they compound:\n\n• $5/day coffee = $150/month = $1,800/year\n• $12/day lunch = $360/month = $4,320/year\n\nYou don't have to cut everything — just be intentional about which small pleasures you keep.")
            ]
        ),
        LearnTopic(
            title: "Credit Cards",
            subtitle: "Use wisely, avoid traps",
            icon: "creditcard.fill",
            color: .orange,
            content: [
                LessonSection(heading: "Credit 101", body: "A credit card lets you borrow money to make purchases. Used responsibly, it builds your credit score. Used poorly, it can lead to crushing debt."),
                LessonSection(heading: "Golden Rules", body: "• Pay your full balance every month — ALWAYS\n• Never spend more than you can afford to pay off\n• Keep utilization below 30% of your limit\n• Set up autopay for at least the minimum"),
                LessonSection(heading: "Building Credit as a Student", body: "Good credit helps you get apartments, car loans, and even jobs later. Start with a student credit card, use it for one recurring expense (like a subscription), and pay it off monthly.")
            ]
        ),
        LearnTopic(
            title: "Student Loans",
            subtitle: "Understand your debt",
            icon: "building.columns.fill",
            color: .blue,
            content: [
                LessonSection(heading: "Types of Loans", body: "• Subsidized: Government pays interest while you're in school\n• Unsubsidized: Interest accrues from day one\n• Private: From banks/lenders, usually higher rates\n\nAlways max out subsidized loans before taking unsubsidized ones."),
                LessonSection(heading: "Repayment Strategies", body: "• Avalanche method: Pay highest interest rate first (saves most money)\n• Snowball method: Pay smallest balance first (builds momentum)\n• Income-driven repayment: Payments based on what you earn"),
                LessonSection(heading: "Key Numbers to Know", body: "Know your total loan balance, interest rates, and monthly payments BEFORE you graduate. Use a loan calculator to understand the true cost over time.")
            ]
        ),
        LearnTopic(
            title: "Investing Basics",
            subtitle: "Start early, grow more",
            icon: "chart.line.uptrend.xyaxis",
            color: .teal,
            content: [
                LessonSection(heading: "Why Start Now?", body: "Time is your biggest advantage. $100/month invested at 20 could grow to over $300,000 by 60 thanks to compound interest. The same investment starting at 30 grows to only ~$150,000."),
                LessonSection(heading: "Getting Started", body: "• Open a Roth IRA (tax-free growth!)\n• Start with index funds (low fees, diversified)\n• Use micro-investing apps to invest spare change\n• Never invest money you'll need within 5 years"),
                LessonSection(heading: "Key Terms", body: "• Stock: Ownership in a company\n• Bond: Lending money to a company/government\n• Index Fund: A basket of many stocks\n• Compound Interest: Earning returns on your returns")
            ]
        ),
        LearnTopic(
            title: "Side Hustles",
            subtitle: "Boost your income",
            icon: "bolt.fill",
            color: .yellow,
            content: [
                LessonSection(heading: "Student-Friendly Income", body: "• Tutoring (especially in subjects you ace)\n• Freelance writing, design, or coding\n• Campus jobs (often flexible with classes)\n• Selling notes or study guides\n• Reselling textbooks"),
                LessonSection(heading: "Managing Extra Income", body: "When you earn extra, split it:\n\n• 50% to savings/debt\n• 30% to spending money\n• 20% to investing\n\nDon't let lifestyle creep eat all your extra earnings!"),
                LessonSection(heading: "Tax Basics", body: "If you earn over ~$400 from freelancing, you'll owe self-employment taxes. Set aside 25-30% of freelance income for taxes. Keep receipts for business expenses!")
            ]
        ),
    ]
}

struct LessonSection: Identifiable {
    let id = UUID()
    let heading: String
    let body: String
}

// MARK: - Topic Detail View
struct TopicDetailView: View {
    let topic: LearnTopic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(topic.color.opacity(0.15))
                                .frame(width: 56, height: 56)

                            Image(systemName: topic.icon)
                                .font(.title2)
                                .foregroundStyle(topic.color)
                        }

                        VStack(alignment: .leading) {
                            Text(topic.title)
                                .font(.title2.bold())
                            Text("\(topic.content.count) sections")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ForEach(Array(topic.content.enumerated()), id: \.element.id) { index, section in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(topic.color)
                                    .clipShape(Circle())

                                Text(section.heading)
                                    .font(.headline)
                            }

                            Text(section.body)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                        .staggered(index: index)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Quiz View
struct QuizView: View {
    @State private var currentQuestion = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showResult = false
    @State private var showConfetti = false

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            question: "What percentage of your income should ideally go to savings according to the 50/30/20 rule?",
            answers: ["50%", "30%", "20%", "10%"],
            correctIndex: 2
        ),
        QuizQuestion(
            question: "What's the best way to use a credit card as a student?",
            answers: ["Max it out for rewards", "Pay minimum balance only", "Pay full balance monthly", "Avoid credit cards entirely"],
            correctIndex: 2
        ),
        QuizQuestion(
            question: "Which type of student loan is best to take first?",
            answers: ["Private loans", "Unsubsidized federal", "Subsidized federal", "Credit card cash advance"],
            correctIndex: 2
        ),
        QuizQuestion(
            question: "If you invest $100/month starting at age 20 with 8% returns, approximately how much will you have at 60?",
            answers: ["$48,000", "$150,000", "$310,000", "$500,000"],
            correctIndex: 2
        ),
        QuizQuestion(
            question: "What's the 'latte factor'?",
            answers: ["Coffee makes you spend more", "Small daily expenses add up significantly", "Expensive coffee is worth it", "You should never buy coffee"],
            correctIndex: 1
        ),
    ]

    var body: some View {
        VStack(spacing: 24) {
            if showResult {
                resultView
            } else {
                questionView
            }
        }
        .padding()
        .navigationTitle("Finance Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            ConfettiView(isActive: showConfetti)
        }
    }

    private var questionView: some View {
        VStack(spacing: 24) {
            // Progress
            HStack {
                Text("Question \(currentQuestion + 1)/\(questions.count)")
                    .font(.subheadline.bold())
                Spacer()
                Text("Score: \(score)")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.primary)
            }

            ProgressView(value: Double(currentQuestion), total: Double(questions.count))
                .tint(AppTheme.primary)

            Spacer()

            Text(questions[currentQuestion].question)
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                ForEach(0..<questions[currentQuestion].answers.count, id: \.self) { index in
                    Button {
                        answerSelected(index)
                    } label: {
                        HStack {
                            Text(questions[currentQuestion].answers[index])
                                .font(.subheadline)
                                .foregroundStyle(answerColor(for: index))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if let selected = selectedAnswer {
                                if index == questions[currentQuestion].correctIndex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                } else if index == selected {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                        .padding()
                        .background(answerBackground(for: index))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(selectedAnswer != nil)
                }
            }

            if selectedAnswer != nil {
                Button {
                    nextQuestion()
                } label: {
                    Text(currentQuestion < questions.count - 1 ? "Next Question" : "See Results")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(BounceButtonStyle())
            }
        }
    }

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()

            let percentage = Double(score) / Double(questions.count) * 100

            ZStack {
                ProgressRing(
                    progress: Double(score) / Double(questions.count),
                    lineWidth: 12,
                    gradient: percentage >= 60 ? AppTheme.successGradient : AppTheme.accentGradient,
                    size: 150
                )

                VStack {
                    Text("\(score)/\(questions.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Correct")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text(percentage >= 80 ? "Finance Whiz! 🎉" : percentage >= 60 ? "Good job! 💪" : "Keep learning! 📚")
                .font(.title2.bold())

            Text(percentage >= 80 ? "You really know your stuff!" : percentage >= 60 ? "You're on the right track." : "Check out our Learn section to boost your knowledge.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .onAppear {
            let percentage = Double(score) / Double(questions.count) * 100
            if percentage >= 80 {
                showConfetti = true
                HapticManager.shared.notification(.success)
            }
        }
    }

    private func answerSelected(_ index: Int) {
        selectedAnswer = index
        if index == questions[currentQuestion].correctIndex {
            score += 1
            HapticManager.shared.notification(.success)
        } else {
            HapticManager.shared.notification(.error)
        }
    }

    private func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            selectedAnswer = nil
        } else {
            showResult = true
        }
    }

    private func answerColor(for index: Int) -> Color {
        guard let selected = selectedAnswer else { return .primary }
        if index == questions[currentQuestion].correctIndex { return .green }
        if index == selected { return .red }
        return .primary
    }

    private func answerBackground(for index: Int) -> Color {
        guard let selected = selectedAnswer else { return Color(.systemGray6) }
        if index == questions[currentQuestion].correctIndex { return .green.opacity(0.1) }
        if index == selected { return .red.opacity(0.1) }
        return Color(.systemGray6)
    }
}

struct QuizQuestion {
    let question: String
    let answers: [String]
    let correctIndex: Int
}
