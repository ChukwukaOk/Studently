# Studently

**Smart budgeting for students, anywhere in the world.**

A personal finance app built with SwiftUI for students, by students. Track spending, set budgets, split bills with friends, and build financial literacy — all in one beautifully designed iOS app.

---

## Features

### Dashboard
Real-time balance overview with monthly spending progress, income vs. expenses, and quick-access actions — all at a glance.

### Category Budgets
Set spending limits for food, transport, entertainment, and more. Visual progress bars update in real-time so you always know where you stand.

### Bill Splitting
Split any bill with friends, adjust tip percentages, and share the breakdown instantly via iMessage or clipboard.

### Financial Health Score
A custom 5-factor algorithm scores your financial wellness from 0–100:

| Factor | What It Measures |
|--------|-----------------|
| Budget Adherence | Are you staying within your limits? |
| Savings Progress | Are you hitting your savings goals? |
| Tracking Consistency | Are you logging expenses regularly? |
| Spending Diversity | Are your expenses spread across categories? |
| Engagement | How actively are you using the app? |

### Achievements
15 unlockable badges that gamify good money habits — from logging your first expense to maintaining a 7-day streak.

### Learning Center
6 financial literacy topics (budgeting, saving, credit, loans, investing, side hustles) with an interactive quiz to test your knowledge.

### Spending Insights
Charts powered by Swift Charts showing spending trends by week, month, or semester, with smart tips based on your habits.

### Multi-Currency Support
Built with international students in mind. Switch between **5 currencies** that update across every screen instantly:

| Currency | Symbol |
|----------|--------|
| CAD | CA$ |
| USD | $ |
| EUR | &euro; |
| INR | &rupee; |
| PKR | Rs |

---

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **SwiftUI** | Declarative UI with custom animations & haptics |
| **SwiftData** | On-device persistence with reactive `@Query` updates |
| **Swift Charts** | Native spending trend & category visualizations |
| **Custom Design System** | Gradients, card components, bounce animations, progress rings |

**Zero external dependencies.** The entire app runs on pure Apple frameworks.

---

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/ChukwukaOk/Studently.git
   ```
2. Open `Studently.xcodeproj` in Xcode
3. Build and run on a simulator or device (iPhone recommended)

---

## Architecture

```
Studently/
├── StudentlyApp.swift          # App entry point & SwiftData container
├── Models/
│   ├── Models.swift            # Transaction, Budget, SavingsGoal, UserProfile
│   ├── Achievements.swift      # 15 achievement definitions & unlock logic
│   └── FinancialHealthScore.swift  # 5-factor scoring algorithm
├── Theme/
│   └── AppTheme.swift          # Colors, gradients, formatters, design tokens
└── Views/
    ├── ContentView.swift       # Tab bar, onboarding flow
    ├── Dashboard/              # Home screen with balance & stats
    ├── Budget/                 # Category budget management
    ├── BillSplit/              # Bill splitting calculator
    ├── Insights/               # Spending charts & smart tips
    ├── HealthScore/            # Financial wellness score
    ├── Achievements/           # Badge collection
    ├── Learn/                  # Financial literacy lessons & quiz
    ├── Profile/                # User profile, settings, savings goals
    ├── Transactions/           # Add transaction flow
    └── Components/             # Shared UI (TransactionRow, SplashScreen, etc.)
```

---

## License

This project was built for a hackathon. All rights reserved.
