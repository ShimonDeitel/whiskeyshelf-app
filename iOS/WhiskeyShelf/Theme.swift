import SwiftUI

/// Unique palette for Whiskey Shelf: amber cask oak.
enum Theme {
    static let accent = Color(hex: "#B5691F")
    static let background = Color(hex: "#130E09")
    static let surface = Color(hex: "#221A12")
    static let textPrimary = Color(hex: "#F5E9D9")
    static let textMuted = Color(hex: "#B89571")

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 16
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
