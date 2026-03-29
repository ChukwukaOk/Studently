import SwiftUI

// MARK: - App Theme
struct AppTheme {
    // Primary gradient - vibrant purple to blue
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "6C63FF"), Color(hex: "4ECDC4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [Color(hex: "00B09B"), Color(hex: "96C93D")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)

    static let primary = Color(hex: "6C63FF")
    static let secondary = Color(hex: "4ECDC4")
    static let accent = Color(hex: "FF6B6B")
    static let success = Color(hex: "00B09B")
    static let warning = Color(hex: "FFD93D")
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCard())
    }

    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// MARK: - Supported Currencies
enum SupportedCurrency: String, CaseIterable, Identifiable {
    case cad = "CAD"
    case usd = "USD"
    case eur = "EUR"
    case inr = "INR"
    case pkr = "PKR"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .cad: return "CA$"
        case .usd: return "$"
        case .eur: return "€"
        case .inr: return "₹"
        case .pkr: return "Rs"
        }
    }

    var flag: String {
        switch self {
        case .cad: return "🇨🇦"
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .inr: return "🇮🇳"
        case .pkr: return "🇵🇰"
        }
    }

    var label: String {
        switch self {
        case .cad: return "Canadian Dollar"
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .inr: return "Indian Rupee"
        case .pkr: return "Pakistani Rupee"
        }
    }
}

// MARK: - Formatters
struct CurrencyFormatter {
    private static let currencyKey = "activeCurrency"

    static var activeCurrency: String {
        get { UserDefaults.standard.string(forKey: currencyKey) ?? "CAD" }
        set { UserDefaults.standard.set(newValue, forKey: currencyKey) }
    }

    static func format(_ value: Double, currency: String? = nil) -> String {
        let code = currency ?? activeCurrency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
