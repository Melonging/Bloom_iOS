import SwiftUI

/// Story-style flower used on the Home tab.
/// Mirrors `renderStoryFlower()` from bloom.html.
struct StoryFlowerView: View {
    let mapped: [Mapping]
    let doneIds: Set<Int>
    let onToggle: (Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let n = max(mapped.count, 1)

            // Geometry — direct port from JS
            let hdH = H * 0.33
            let ftH = H * 0.23
            let midH = H - hdH - ftH
            let fcx = W / 2
            let fcy = hdH + midH * 0.50

            let maxR = min(W * 0.42, midH * 0.47)
            let orbit = maxR * 0.585
            let ry = maxR * 0.43
            let rx = ry * 0.655
            let cr = ry * 0.45

            ZStack {
                // Stem
                StemShape(
                    start: CGPoint(x: fcx, y: fcy + orbit * 0.34),
                    end: CGPoint(x: fcx, y: fcy + orbit * 0.34 + orbit * 0.72)
                )
                .stroke(Color(red: 0x8A/255, green: 0x9E/255, blue: 0x60/255),
                        style: StrokeStyle(lineWidth: max(5, orbit * 0.095), lineCap: .round))

                // Leaves
                let ls = orbit * 0.15
                let ly1 = fcy + orbit * 0.54
                let ly2 = fcy + orbit * 0.70

                Ellipse()
                    .fill(Color(red: 0x7A/255, green: 0x90/255, blue: 0x50/255).opacity(0.88))
                    .frame(width: ls * 2.7, height: ls * 1.24)
                    .rotationEffect(.degrees(-35))
                    .position(x: fcx - ls * 1.4, y: ly1)

                Ellipse()
                    .fill(Color(red: 0x8A/255, green: 0xAA/255, blue: 0x60/255).opacity(0.82))
                    .frame(width: ls * 2.5, height: ls * 1.16)
                    .rotationEffect(.degrees(33))
                    .position(x: fcx + ls * 1.3, y: ly2)

                // Petals
                ForEach(Array(mapped.enumerated()), id: \.element.id) { i, m in
                    let isDone = doneIds.contains(m.id)
                    let deg = Double(i) * (360.0 / Double(n)) - 90.0
                    let rad = deg * .pi / 180.0
                    let px = fcx + cos(rad) * orbit
                    let py = fcy + sin(rad) * orbit

                    PetalView(
                        rx: rx, ry: ry, isDone: isDone, name: m.name
                    )
                    .rotationEffect(.degrees(deg + 90))
                    .position(x: px, y: py)
                    .onTapGesture { onToggle(m.id) }
                }

                // Center
                let doneCount = mapped.filter { doneIds.contains($0.id) }.count
                let lit = doneCount > 0

                Circle()
                    .fill(lit ? AnyShapeStyle(centerOnGradient) : AnyShapeStyle(centerOffGradient))
                    .frame(width: cr * 2, height: cr * 2)
                    .overlay(
                        Circle().strokeBorder(
                            lit ? Color(red: 0xC8/255, green: 0x90/255, blue: 0x20/255)
                                : Color(red: 0xD5/255, green: 0xC9/255, blue: 0xB5/255),
                            lineWidth: 1)
                    )
                    .shadow(color: lit ? Color(red: 0xF5/255, green: 0xC8/255, blue: 0x4A/255).opacity(0.6) : .clear,
                            radius: lit ? 8 : 0)
                    .position(x: fcx, y: fcy)

                Text("\(doneCount)/\(mapped.count)")
                    .font(BloomFont.body(cr * 0.52, weight: .medium))
                    .foregroundColor(lit
                        ? Color(red: 0x7A/255, green: 0x4E/255, blue: 0x08/255)
                        : Color(red: 0xA8/255, green: 0xA0/255, blue: 0x98/255))
                    .position(x: fcx, y: fcy)
            }
            .compositingGroup()
            .shadow(color: Color(red: 0x50/255, green: 0x3C/255, blue: 0x1E/255).opacity(0.12),
                    radius: 14, x: 0, y: 6)
        }
    }

    private var centerOnGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color(red: 0xF5/255, green: 0xC8/255, blue: 0x4A/255),
                Color(red: 0xC8/255, green: 0x80/255, blue: 0x10/255),
            ],
            center: UnitPoint(x: 0.45, y: 0.35),
            startRadius: 0, endRadius: 60
        )
    }
    private var centerOffGradient: RadialGradient {
        RadialGradient(
            colors: [
                Color(red: 0xDF/255, green: 0xDA/255, blue: 0xD0/255),
                Color(red: 0xC4/255, green: 0xBC/255, blue: 0xB0/255),
            ],
            center: UnitPoint(x: 0.45, y: 0.35),
            startRadius: 0, endRadius: 60
        )
    }
}

private struct StemShape: Shape {
    let start: CGPoint
    let end: CGPoint
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: start)
        p.addLine(to: end)
        return p
    }
}

private struct PetalView: View {
    let rx: CGFloat
    let ry: CGFloat
    let isDone: Bool
    let name: String

    var body: some View {
        let onGrad = RadialGradient(
            colors: [
                .white,
                Color(red: 0xFE/255, green: 0xF3/255, blue: 0xDB/255),
                Color(red: 0xF0/255, green: 0xDA/255, blue: 0xA8/255),
            ],
            center: UnitPoint(x: 0.4, y: 0.28),
            startRadius: 0,
            endRadius: max(rx, ry)
        )
        let offGrad = RadialGradient(
            colors: [
                Color(red: 0xF8/255, green: 0xF5/255, blue: 0xEF/255),
                Color(red: 0xE6/255, green: 0xDF/255, blue: 0xCF/255),
            ],
            center: UnitPoint(x: 0.4, y: 0.30),
            startRadius: 0,
            endRadius: max(rx, ry)
        )

        ZStack {
            Ellipse()
                .fill(isDone ? AnyShapeStyle(onGrad) : AnyShapeStyle(offGrad))
                .overlay(
                    Ellipse().strokeBorder(
                        isDone
                            ? Color(red: 0xCC/255, green: 0xA0/255, blue: 0x30/255)
                            : Color(red: 0xC8/255, green: 0xC0/255, blue: 0xB2/255),
                        lineWidth: isDone ? 1.8 : 1)
                )
                .frame(width: rx * 2, height: ry * 2)
                .shadow(color: isDone ? Color(red: 0xF0/255, green: 0xDA/255, blue: 0xA8/255).opacity(0.6) : .clear,
                        radius: isDone ? 3 : 0)

            PetalTextView(name: name, ry: ry, isDone: isDone)
                .frame(width: rx * 2, height: ry * 2)
        }
        .frame(width: rx * 2, height: ry * 2)
        .contentShape(Ellipse())
    }
}

private struct PetalTextView: View {
    let name: String
    let ry: CGFloat
    let isDone: Bool

    var body: some View {
        let lines = petalLines(name)
        let fs = max(8, ry * 0.188)
        VStack(spacing: fs * 0.38) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(BloomFont.body(fs, weight: .medium))
                    .foregroundColor(isDone
                        ? Color(red: 0x7A/255, green: 0x4E/255, blue: 0x08/255)
                        : Color(red: 0x9A/255, green: 0x90/255, blue: 0x88/255))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    private func petalLines(_ name: String) -> [String] {
        if name.isEmpty { return [""] }
        let w = name.split(separator: " ").map(String.init)
        if w.count <= 1 { return [name] }
        if w.count == 2 { return w }
        let m = (w.count + 1) / 2
        return [w.prefix(m).joined(separator: " "),
                w.suffix(from: m).joined(separator: " ")]
    }
}
