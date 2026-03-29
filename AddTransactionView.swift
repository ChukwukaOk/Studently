import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: TransactionCategory = .food
    @State private var isIncome = false
    @State private var date = Date()
    @State private var note = ""
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Income/Expense Toggle
                    HStack(spacing: 0) {
                        toggleButton(title: "Expense", isSelected: !isIncome) {
                            withAnimation(.spring(response: 0.3)) { isIncome = false }
                        }
                        toggleButton(title: "Income", isSelected: isIncome) {
                            withAnimation(.spring(response: 0.3)) { isIncome = true }
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)

                    // Amount Input
                    VStack(spacing: 8) {
                        Text(isIncome ? "Amount Received" : "Amount Spent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(SupportedCurrency(rawValue: CurrencyFormatter.activeCurrency)?.symbol ?? "$")
                                .font(.system(size: 30, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $amount)
                                .font(.system(size: 50, weight: .bold, design: .rounded))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: 250)
                    }
                    .padding(.vertical, 8)

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)

                        TextField("What was this for?", text: $title)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    // Category Selection
                    if !isIncome {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)

                            categoryGrid
                        }
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)

                        Button {
                            showDatePicker.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(AppTheme.primary)
                                Text(date.formatted(date: .long, time: .omitted))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        if showDatePicker {
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .tint(AppTheme.primary)
                        }
                    }
                    .padding(.horizontal)

                    // Note
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.subheadline.bold())
                            .foregroundStyle(.secondary)

                        TextField("Add a note...", text: $note, axis: .vertical)
                            .lineLimit(3...5)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    // Save Button
                    Button {
                        saveTransaction()
                    } label: {
                        Text("Save Transaction")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                (title.isEmpty || amount.isEmpty)
                                    ? AnyShapeStyle(Color.gray)
                                    : AnyShapeStyle(AppTheme.primaryGradient)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Category Grid
    private var categoryGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ForEach(TransactionCategory.expenseCategories) { category in
                Button {
                    withAnimation(.spring(response: 0.2)) {
                        selectedCategory = category
                    }
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(selectedCategory == category ? category.color : category.color.opacity(0.12))
                                .frame(width: 48, height: 48)

                            Image(systemName: category.icon)
                                .font(.body)
                                .foregroundStyle(selectedCategory == category ? .white : category.color)
                        }

                        Text(category.rawValue.components(separatedBy: " ").first ?? "")
                            .font(.caption2)
                            .foregroundStyle(selectedCategory == category ? category.color : .secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Toggle Button
    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? AppTheme.primaryGradient : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Save
    private func saveTransaction() {
        let transaction = Transaction(
            title: title,
            amount: Double(amount) ?? 0,
            category: isIncome ? .income : selectedCategory,
            date: date,
            note: note,
            isIncome: isIncome
        )
        modelContext.insert(transaction)
        try? modelContext.save()
        HapticManager.shared.notification(.success)
        dismiss()
    }
}
