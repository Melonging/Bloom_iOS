import SwiftUI

enum BloomColor {
    static let cream      = Color(red: 0xF5/255, green: 0xF0/255, blue: 0xE8/255)
    static let cream2     = Color(red: 0xED/255, green: 0xE8/255, blue: 0xDF/255)
    static let cream3     = Color(red: 0xE4/255, green: 0xDD/255, blue: 0xCF/255)
    static let warmWhite  = Color(red: 0xFA/255, green: 0xF8/255, blue: 0xF4/255)
    static let ink        = Color(red: 0x2E/255, green: 0x28/255, blue: 0x20/255)
    static let ink2       = Color(red: 0x6B/255, green: 0x63/255, blue: 0x58/255)
    static let ink3       = Color(red: 0x9E/255, green: 0x94/255, blue: 0x88/255)
    static let gold       = Color(red: 0xE8/255, green: 0xA0/255, blue: 0x20/255)
    static let goldLight  = Color(red: 0xF5/255, green: 0xD0/255, blue: 0x80/255)
    static let goldDim    = Color(red: 0xC8/255, green: 0x80/255, blue: 0x10/255)
    static let sage       = Color(red: 0x7A/255, green: 0x8F/255, blue: 0x5A/255)
    static let rose       = Color(red: 0xC8/255, green: 0x54/255, blue: 0x6A/255)
    static let brown      = Color(red: 0x8B/255, green: 0x6F/255, blue: 0x52/255)
    static let border     = Color(red: 0xDD/255, green: 0xD8/255, blue: 0xCF/255)
    static let borderLight = Color(red: 0xED/255, green: 0xE8/255, blue: 0xDF/255)
    static let shadow     = Color(red: 0x2E/255, green: 0x28/255, blue: 0x20/255).opacity(0.08)
    static let shadow2    = Color(red: 0x2E/255, green: 0x28/255, blue: 0x20/255).opacity(0.15)
}

enum BloomFont {
    static func serif(_ size: CGFloat, italic: Bool = false) -> Font {
        let base = Font.custom("DM Serif Display", size: size)
        return italic ? base.italic() : base
    }
    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom("Noto Sans KR", size: size).weight(weight)
    }
}

enum BloomRadius {
    static let r: CGFloat = 14
    static let rSm: CGFloat = 10
}

struct BloomCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(EdgeInsets(top: 16, leading: 17.6, bottom: 16, trailing: 17.6))
            .background(BloomColor.warmWhite)
            .overlay(
                RoundedRectangle(cornerRadius: BloomRadius.r)
                    .strokeBorder(BloomColor.border, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: BloomRadius.r))
            .shadow(color: BloomColor.shadow, radius: 4, x: 0, y: 2)
    }
}

extension View {
    func bloomCard() -> some View { modifier(BloomCardStyle()) }
}

/// SF Symbol names used for the icon picker. Order matches the original HTML's emoji palette.
let BLOOM_ICONS: [String] = [
    "figure.run",            // 🏃
    "drop.fill",             // 💧
    "book.fill",             // 📚
    "figure.mind.and.body",  // 🧘
    "pills.fill",            // 💊
    "leaf.fill",             // 🌿
    "pencil",                // ✏️
    "music.note",            // 🎵
    "fork.knife",            // 🍎/식사
    "moon.zzz.fill",         // 😴
    "sparkles",              // 🧹
    "dumbbell.fill",         // 💪
    "face.smiling",          // 🧴/스킨케어
    "figure.walk",           // 🚶
    "cup.and.saucer.fill",   // ☕
]

let BLOOM_COLORS: [Color] = [
    Color(red: 0xE8/255, green: 0xA0/255, blue: 0x20/255),
    Color(red: 0x7A/255, green: 0x8F/255, blue: 0x5A/255),
    Color(red: 0x8B/255, green: 0x6F/255, blue: 0x52/255),
    Color(red: 0xC8/255, green: 0x54/255, blue: 0x6A/255),
    Color(red: 0x5A/255, green: 0x7A/255, blue: 0x8F/255),
    Color(red: 0xA6/255, green: 0x7C/255, blue: 0x52/255),
    Color(red: 0x9E/255, green: 0x94/255, blue: 0x88/255),
    Color(red: 0x6B/255, green: 0x8F/255, blue: 0x7A/255),
]

let BLOOM_COLOR_HEX: [String] = [
    "#E8A020","#7A8F5A","#8B6F52","#C8546A","#5A7A8F","#A67C52","#9E9488","#6B8F7A",
]

extension Color {
    init(hex: String) {
        var s = hex
        if s.hasPrefix("#") { s.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self = Color(red: r, green: g, blue: b)
    }
}

let WEEK_DAYS_KO: [String] = ["일","월","화","수","목","금","토"]
