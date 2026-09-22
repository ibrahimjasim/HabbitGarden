//
//  BrickTheme.swift
//  HabitGarden
//
//  Created by Ibrahim Jasim Alsalih on 2026-09-01.
//

import SwiftUI


//
//  BrickTheme.swift
//  HabitGarden
//
//  Shared design tokens for the brick/toy visual style — chunky rounded
//  shapes, thick ink outlines, hard offset shadows (no blur).
//

import SwiftUI

// MARK: - Palette

enum Brick {
    static let ink    = Color(hex: "#2B2118")
    static let cream  = Color(hex: "#FBF6EC")
    static let red    = Color(hex: "#E8483C")
    static let yellow = Color(hex: "#F5B72E")
    static let blue   = Color(hex: "#3E86F0")
    static let green  = Color(hex: "#33AE64")
    static let purple = Color(hex: "#8C5CF5")
    static let brown  = Color(hex: "#A9673B")
    static let white  = Color.white
}

// MARK: - Hex color support

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }

    /// Rough relative luminance — used to flip label text between
    /// ink and white depending on how bright the card color is.
    var isLight: Bool {
        guard let c = UIColor(self).cgColor.components, c.count >= 3 else { return true }
        let luminance = 0.299 * c[0] + 0.587 * c[1] + 0.114 * c[2]
        return luminance > 0.6
    }

    var brickTextColor: Color { isLight ? Brick.ink : .white }
}

// MARK: - Fonts
// Falls back to the system font automatically if a name below isn't
// registered yet — nothing crashes if Step 1 hasn't happened.

extension Font {
    static func brickTitle(_ size: CGFloat) -> Font { .custom("Fredoka-Bold", size: size) }
    static func brickHeading(_ size: CGFloat) -> Font { .custom("Fredoka-SemiBold", size: size) }
    static func brickBody(_ size: CGFloat) -> Font { .custom("Nunito-Bold", size: size) }
    static func brickBodyHeavy(_ size: CGFloat) -> Font { .custom("Nunito-ExtraBold", size: size) }
}

// MARK: - The "brick card" look
// A filled, rounded, thick-bordered shape with a crisp offset shadow
// (radius: 0 on SwiftUI's .shadow gives a hard edge, no blur).

struct BrickCardBackground: ViewModifier {
    var fill: Color
    var cornerRadius: CGFloat = 18
    var borderWidth: CGFloat = 3
    var shadowOffset: CGFloat = 5

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Brick.ink, lineWidth: borderWidth)
                    )
            )
            .compositingGroup()
            .shadow(color: Brick.ink, radius: 0, x: shadowOffset, y: shadowOffset)
    }
}

extension View {
    func brickCard(fill: Color, cornerRadius: CGFloat = 18, borderWidth: CGFloat = 3, shadowOffset: CGFloat = 5) -> some View {
        modifier(BrickCardBackground(fill: fill, cornerRadius: cornerRadius, borderWidth: borderWidth, shadowOffset: shadowOffset))
    }
}

// MARK: - Studs
// The little circles along a brick's top edge. Overlay this with
// alignment: .top on anything using brickCard().

struct BrickStuds: View {
    var count: Int = 3
    var diameter: CGFloat = 10
    var color: Color

    var body: some View {
        HStack {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: diameter, height: diameter)
                    .overlay(Circle().stroke(Brick.ink, lineWidth: 2))
                if i < count - 1 { Spacer() }
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 1)
        .offset(y: -diameter / 2)
    }
}

// MARK: - Baseplate background
// The dot-grid "toy baseplate" texture used behind the habit list.

struct BaseplateBackground: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 22
            let dot = Path(ellipseIn: CGRect(x: -1.5, y: -1.5, width: 3, height: 3))
            var y: CGFloat = 10
            while y < size.height {
                var x: CGFloat = 10
                while x < size.width {
                    context.translateBy(x: x, y: y)
                    context.fill(dot, with: .color(Brick.ink.opacity(0.10)))
                    context.translateBy(x: -x, y: -y)
                    x += spacing
                }
                y += spacing
            }
        }
        .background(Brick.cream)
        .ignoresSafeArea()
    }
}
