import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    @AppStorage("activeCurrency") private var activeCurrency = "CAD"

    var body: some View {
        HStack(spacing: 14) {
            // Category Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(transaction.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: transaction.category.icon)
                    .font(.body)
                    .foregroundStyle(transaction.category.color)
            }

            // Details
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Amount
            Text("\(transaction.isIncome ? "+" : "-")\(CurrencyFormatter.format(transaction.amount))")
                .font(.subheadline.bold())
                .foregroundStyle(transaction.isIncome ? .green : .primary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
