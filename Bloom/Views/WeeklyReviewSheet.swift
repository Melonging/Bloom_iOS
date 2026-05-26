import SwiftUI

struct WeeklyReviewSheet: View {
    @EnvironmentObject var data: AppData
    var onClose: () -> Void

    var body: some View {
        let wd = data.weekData()
        let cal = Calendar(identifier: .gregorian)
        let endDate = cal.date(byAdding: .day, value: 6, to: wd.monday)!
        let range = "\(format(wd.monday)) — \(format(endDate))"
        let bestKeys = Set(wd.weekDays.filter { !$0.isFuture }.map(\.key))
        let counts = data.routineCounts(in: bestKeys)
        let best = wd.mapped.sorted { (counts[$0.id] ?? 0) > (counts[$1.id] ?? 0) }.first

        ScrollView {
            VStack(spacing: 0) {
                handleBar
                header(range: range)
                weekFlower(days: wd.weekDays, pct: wd.pct)
                stats(pct: wd.pct, perfect: wd.perfectDays, total: wd.totalDone)
                    .padding(.top, 14)
                daysRow(days: wd.weekDays)
                    .padding(.top, 22)
                divider
                if let m = best {
                    bestRow(m: m, count: counts[m.id] ?? 0)
                }
                Text(message(for: wd.pct))
                    .font(BloomFont.body(13))
                    .foregroundColor(Color.white.opacity(0.38))
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 24)
                closeButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 56)
        }
        .background(Color(red: 0x1E/255, green: 0x16/255, blue: 0x10/255))
        .clipShape(RoundedTopCorners(radius: 24))
    }

    private var handleBar: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.1))
                .frame(width: 36, height: 4)
                .padding(.top, 16)
                .padding(.bottom, 2)
        }
    }

    private func header(range: String) -> some View {
        VStack(spacing: 6) {
            Text("이번 주 리뷰")
                .font(BloomFont.body(10))
                .tracking(2)
                .foregroundColor(Color.white.opacity(0.25))
                .textCase(.uppercase)
            Text(range)
                .font(BloomFont.serif(23))
                .foregroundColor(Color.white.opacity(0.88))
        }
        .padding(.top, 12)
        .padding(.bottom, 24)
    }

    private func weekFlower(days: [AppData.WeekDay], pct: Int) -> some View {
        ReviewFlowerView(days: days, pct: pct)
            .frame(width: 200, height: 200)
            .frame(maxWidth: .infinity)
    }

    private func stats(pct: Int, perfect: Int, total: Int) -> some View {
        HStack(spacing: 10) {
            stat(n: "\(pct)%", label: "달성률")
            stat(n: "\(perfect)", label: "완벽한 날")
            stat(n: "\(total)", label: "총 완료")
        }
    }

    private func stat(n: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(n)
                .font(BloomFont.serif(36))
                .foregroundColor(BloomColor.gold)
            Text(label)
                .font(BloomFont.body(11))
                .foregroundColor(Color.white.opacity(0.3))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18).padding(.horizontal, 12)
        .background(Color.white.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func daysRow(days: [AppData.WeekDay]) -> some View {
        HStack(spacing: 7) {
            ForEach(days) { wd in
                VStack(spacing: 5) {
                    dayDot(wd: wd)
                    Text(wd.day)
                        .font(BloomFont.body(10))
                        .foregroundColor(Color.white.opacity(0.28))
                }
            }
        }
    }

    private func dayDot(wd: AppData.WeekDay) -> some View {
        let bg: Color
        let fg: Color
        let txt: String
        if wd.isFuture {
            bg = Color.white.opacity(0.05); fg = Color.white.opacity(0.18); txt = "—"
        } else if wd.pct >= 1 {
            bg = BloomColor.gold.opacity(0.9); fg = Color(red: 0x1E/255, green: 0x16/255, blue: 0x10/255); txt = "✓"
        } else if wd.pct > 0 {
            let a = 0.2 + wd.pct * 0.55
            bg = BloomColor.gold.opacity(a)
            fg = wd.pct >= 0.5 ? Color(red: 0x1E/255, green: 0x16/255, blue: 0x10/255).opacity(0.8) : Color.white.opacity(0.65)
            txt = "\(Int(round(wd.pct * 100)))%"
        } else {
            bg = Color.white.opacity(0.07); fg = Color.white.opacity(0.22); txt = "·"
        }
        return Text(txt)
            .font(BloomFont.body(10, weight: .medium))
            .foregroundColor(fg)
            .frame(width: 36, height: 36)
            .background(bg)
            .clipShape(Circle())
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 0.5)
            .padding(.top, 24)
            .padding(.bottom, 20)
    }

    private func bestRow(m: Mapping, count: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: m.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(BloomColor.gold)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text("이번 주 베스트 루틴")
                    .font(BloomFont.body(10))
                    .tracking(1)
                    .foregroundColor(BloomColor.gold)
                    .textCase(.uppercase)
                Text(m.name)
                    .font(BloomFont.body(15, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.82))
                Text("이번 주 \(count)일 완료")
                    .font(BloomFont.body(12))
                    .foregroundColor(Color.white.opacity(0.3))
            }
            Spacer()
        }
        .padding(.horizontal, 18).padding(.vertical, 15)
        .background(BloomColor.gold.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(BloomColor.gold.opacity(0.22), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Text("닫기")
                .font(BloomFont.body(14))
                .foregroundColor(Color.white.opacity(0.42))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.07))
                .overlay(
                    Capsule().strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func format(_ d: Date) -> String {
        let cal = Calendar(identifier: .gregorian)
        return "\(cal.component(.month, from: d))/\(cal.component(.day, from: d))"
    }

    private func message(for pct: Int) -> String {
        if pct >= 90 { return "완벽한 한 주예요. 꽃밭 가득 채우고 있어요" }
        if pct >= 70 { return "훌륭해요! 꾸준함이 쌓이고 있어요" }
        if pct >= 50 { return "절반 이상 해냈어요. 조금씩 더 피워봐요" }
        if pct >= 1  { return "시작이 반이에요. 작은 꽃잎 하나하나가 쌓여요" }
        return "이번 주는 쉬어갔네요. 다음 주엔 꽃 한 송이 피워봐요"
    }
}

private struct RoundedTopCorners: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let r = min(radius, min(rect.width, rect.height) / 2)
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        p.addQuadCurve(to: CGPoint(x: rect.minX + r, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + r),
                       control: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

struct ReviewFlowerView: View {
    let days: [AppData.WeekDay]
    let pct: Int

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let cx = W / 2, cy = H / 2
            let orbit = min(W, H) * 0.27

            ZStack {
                ForEach(Array(days.enumerated()), id: \.element.id) { i, wd in
                    let deg = Double(i) * (360.0 / 7.0) - 90.0
                    let rad = deg * .pi / 180
                    let px = cx + cos(rad) * orbit
                    let py = cy + sin(rad) * orbit
                    let lx = cx + cos(rad) * (orbit + 28)
                    let ly = cy + sin(rad) * (orbit + 28)

                    let (fill, stroke): (Color, Color) = {
                        if wd.isFuture {
                            return (Color.white.opacity(0.04), Color.white.opacity(0.08))
                        } else if wd.pct >= 1 {
                            return (BloomColor.gold, Color(red: 0xF5/255, green: 0xC8/255, blue: 0x40/255))
                        } else if wd.pct > 0 {
                            let a = 0.2 + wd.pct * 0.6
                            return (BloomColor.gold.opacity(a),
                                    Color(red: 0xF5/255, green: 0xC8/255, blue: 0x40/255).opacity(a * 0.7))
                        } else {
                            return (Color.white.opacity(0.07), Color.white.opacity(0.1))
                        }
                    }()

                    Ellipse()
                        .fill(fill)
                        .frame(width: 34, height: 54)
                        .overlay(Ellipse().strokeBorder(stroke, lineWidth: 0.8))
                        .rotationEffect(.degrees(deg + 90))
                        .position(x: px, y: py)

                    Text(wd.day)
                        .font(BloomFont.body(9.5))
                        .foregroundColor(
                            wd.isFuture
                                ? Color.white.opacity(0.18)
                                : wd.pct >= 1 ? Color.white.opacity(0.75) : Color.white.opacity(0.4)
                        )
                        .position(x: lx, y: ly + 4)
                }

                Circle()
                    .fill(BloomColor.gold.opacity(0.14))
                    .frame(width: 46, height: 46)
                    .overlay(Circle().strokeBorder(BloomColor.gold.opacity(0.28), lineWidth: 1))
                    .position(x: cx, y: cy)
                Text("\(pct)%")
                    .font(BloomFont.body(12, weight: .medium))
                    .foregroundColor(BloomColor.gold)
                    .position(x: cx, y: cy)
            }
        }
    }
}
