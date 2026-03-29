import SwiftUI

struct BillSplitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var billAmount = ""
    @State private var tipPercentage = 15.0
    @State private var numberOfPeople = 2
    @State private var splitEvenly = true
    @State private var customSplits: [CustomSplit] = []
    @State private var showResult = false
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    private var billTotal: Double { Double(billAmount) ?? 0 }
    private var tipAmount: Double { billTotal * tipPercentage / 100 }
    private var grandTotal: Double { billTotal + tipAmount }
    private var perPerson: Double { numberOfPeople > 0 ? grandTotal / Double(numberOfPeople) : 0 }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Bill Amount
                    billAmountSection

                    // Tip Section
                    tipSection

                    // People Count
                    peopleSection

                    // Result Card
                    if !billAmount.isEmpty {
                        resultCard
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    // Share Split
                    if !billAmount.isEmpty {
                        shareSplitSection
                    }
                }
                .padding()
                .animation(.spring(response: 0.4), value: billAmount)
            }
            .background(AppTheme.secondaryBackground.ignoresSafeArea())
            .navigationTitle("Split Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Bill Amount
    private var billAmountSection: some View {
        VStack(spacing: 12) {
            Text("Bill Amount")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(SupportedCurrency(rawValue: CurrencyFormatter.activeCurrency)?.symbol ?? "$")
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $billAmount)
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: 250)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }

    // MARK: - Tip Section
    private var tipSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Tip")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(tipPercentage))% (\(CurrencyFormatter.format(tipAmount)))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Quick tip buttons
            HStack(spacing: 10) {
                ForEach([0, 10, 15, 18, 20], id: \.self) { percent in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            tipPercentage = Double(percent)
                        }
                        HapticManager.shared.selection()
                    } label: {
                        Text("\(percent)%")
                            .font(.subheadline.bold())
                            .foregroundStyle(tipPercentage == Double(percent) ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(tipPercentage == Double(percent) ? AppTheme.primaryGradient : LinearGradient(colors: [Color(.systemGray5)], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                    }
                }
            }

            Slider(value: $tipPercentage, in: 0...30, step: 1)
                .tint(AppTheme.primary)
        }
        .cardStyle()
    }

    // MARK: - People Section
    private var peopleSection: some View {
        VStack(spacing: 12) {
            Text("Number of People")
                .font(.subheadline.bold())

            HStack(spacing: 20) {
                Button {
                    if numberOfPeople > 1 {
                        numberOfPeople -= 1
                        HapticManager.shared.impact(.light)
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(numberOfPeople > 1 ? AppTheme.primary : .gray)
                }

                // People icons
                HStack(spacing: -8) {
                    ForEach(0..<min(numberOfPeople, 6), id: \.self) { i in
                        Circle()
                            .fill(personColor(for: i))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            )
                            .staggered(index: i)
                    }
                    if numberOfPeople > 6 {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text("+\(numberOfPeople - 6)")
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white)
                            )
                    }
                }

                Text("\(numberOfPeople)")
                    .font(.title.bold())
                    .frame(width: 40)
                    .contentTransition(.numericText())

                Button {
                    numberOfPeople += 1
                    HapticManager.shared.impact(.light)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(AppTheme.primary)
                }
            }
        }
        .cardStyle()
    }

    private func personColor(for index: Int) -> Color {
        let colors: [Color] = [AppTheme.primary, AppTheme.secondary, .orange, .pink, .purple, .teal]
        return colors[index % colors.count]
    }

    // MARK: - Result Card
    private var resultCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Each Person Pays")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))

                    Text(CurrencyFormatter.format(perPerson))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText(value: perPerson))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("Bill:")
                        Text(CurrencyFormatter.format(billTotal))
                    }
                    HStack(spacing: 4) {
                        Text("Tip:")
                        Text(CurrencyFormatter.format(tipAmount))
                    }
                    Divider()
                        .background(.white.opacity(0.3))
                    HStack(spacing: 4) {
                        Text("Total:")
                            .bold()
                        Text(CurrencyFormatter.format(grandTotal))
                            .bold()
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(20)
        .background(AppTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: AppTheme.primary.opacity(0.3), radius: 12, y: 6)
    }

    // MARK: - Share Split
    private var shareSplitSection: some View {
        VStack(spacing: 12) {
            Text("Quick Share")
                .font(.subheadline.bold())

            HStack(spacing: 16) {
                shareButton(icon: "message.fill", label: "iMessage", color: .green)
                shareButton(icon: "doc.on.doc.fill", label: "Copy", color: .blue)
                shareButton(icon: "square.and.arrow.up.fill", label: "Share", color: AppTheme.primary)
            }
        }
        .cardStyle()
    }

    private func shareButton(icon: String, label: String, color: Color) -> some View {
        Button {
            HapticManager.shared.impact(.medium)
            if label == "Copy" {
                UIPasteboard.general.string = splitSummary
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .foregroundStyle(color)
                }
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(BounceButtonStyle())
    }

    private var splitSummary: String {
        """
        🧾 Bill Split via Studently
        Bill: \(CurrencyFormatter.format(billTotal))
        Tip (\(Int(tipPercentage))%): \(CurrencyFormatter.format(tipAmount))
        Total: \(CurrencyFormatter.format(grandTotal))
        Split \(numberOfPeople) ways: \(CurrencyFormatter.format(perPerson)) each
        """
    }
}

struct CustomSplit: Identifiable {
    let id = UUID()
    var name: String
    var amount: Double
}
