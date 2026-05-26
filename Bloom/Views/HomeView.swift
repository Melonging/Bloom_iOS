import SwiftUI

struct HomeView: View {
    @EnvironmentObject var data: AppData

    var body: some View {
        GeometryReader { geo in
            ZStack {
                StoryBackground()

                let mp = data.mapped
                let done = data.todaySet
                let doneCount = mp.filter { done.contains($0.id) }.count
                let total = max(mp.count, 1)
                let pct = Int(round(Double(doneCount) / Double(total) * 100))

                StoryFlowerView(
                    mapped: mp,
                    doneIds: done,
                    onToggle: { id in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            data.toggle(id)
                        }
                    }
                )

                VStack(spacing: 0) {
                    storyHeader
                        .padding(.horizontal, max(18, geo.size.width * 0.05))
                        .padding(.top, max(12, geo.size.height * 0.035))
                    Spacer()
                    storyFooter(doneCount: doneCount, total: mp.count, pct: pct)
                        .padding(.horizontal, max(18, geo.size.width * 0.05))
                        .padding(.bottom, max(14, geo.size.height * 0.04))
                        .background(
                            LinearGradient(
                                colors: [
                                    BloomColor.warmWhite,
                                    BloomColor.warmWhite.opacity(0.96),
                                    BloomColor.warmWhite.opacity(0.6),
                                    .clear,
                                ],
                                startPoint: .bottom, endPoint: .top
                            )
                            .frame(height: geo.size.height * 0.30)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .allowsHitTesting(false)
                        )
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var storyHeader: some View {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let month = cal.component(.month, from: now)
        let day = cal.component(.day, from: now)
        let dow = cal.component(.weekday, from: now) - 1 // 0..6
        return VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("bloom")
                    .font(BloomFont.serif(14, italic: true))
                    .tracking(3.6)
                    .foregroundColor(Color(red: 0xB4/255, green: 0xA6/255, blue: 0x96/255))
                Spacer()
                Text("\(month)월 \(day)일 \(WEEK_DAYS_KO[dow])요일")
                    .font(BloomFont.body(11))
                    .foregroundColor(Color(red: 0xA8/255, green: 0x98/255, blue: 0x8A/255))
                    .padding(.horizontal, 10).padding(.vertical, 3)
                    .background(Color.white.opacity(0.45))
                    .overlay(
                        Capsule().strokeBorder(
                            Color(red: 0xC8/255, green: 0xBC/255, blue: 0xAC/255).opacity(0.55),
                            lineWidth: 0.5)
                    )
                    .clipShape(Capsule())
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("오늘의")
                    .font(BloomFont.serif(34))
                    .foregroundColor(BloomColor.ink)
                Text("꽃")
                    .italic()
                    .font(BloomFont.serif(34, italic: true))
                    .foregroundColor(BloomColor.gold)
            }
            .padding(.top, 6)
            Text(subText)
                .font(BloomFont.body(12))
                .foregroundColor(BloomColor.ink3)
                .padding(.top, 2)
        }
    }

    private var subText: String {
        let mp = data.mapped
        let done = data.todaySet
        let doneCount = mp.filter { done.contains($0.id) }.count
        if mp.isEmpty { return "매핑 탭에서 할 일을 연결해보세요" }
        if doneCount == mp.count { return "오늘 모두 완료! 꽃이 활짝 피었어요" }
        if doneCount > 0 { return "\(doneCount)개 완료 · \(mp.count - doneCount)개 남았어요" }
        return "꽃잎을 탭하면 완료돼요"
    }

    private func storyFooter(doneCount: Int, total: Int, pct: Int) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                GeometryReader { p in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0xBE/255, green: 0xB2/255, blue: 0xA0/255).opacity(0.35))
                        Capsule()
                            .fill(LinearGradient(
                                colors: [BloomColor.gold, Color(red: 0xF5/255, green: 0xC8/255, blue: 0x44/255)],
                                startPoint: .leading, endPoint: .trailing))
                            .frame(width: p.size.width * CGFloat(pct) / 100)
                            .animation(.spring(response: 0.65, dampingFraction: 0.7), value: pct)
                    }
                }
                .frame(height: 3.5)

                Text("\(pct)%")
                    .font(BloomFont.body(12, weight: .medium))
                    .foregroundColor(BloomColor.gold)
                    .frame(minWidth: 36, alignment: .trailing)
            }

            HStack(alignment: .bottom) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(data.streakCount())")
                        .font(BloomFont.serif(40))
                        .foregroundColor(BloomColor.gold)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("일 연속")
                            .font(BloomFont.body(11))
                            .foregroundColor(Color(red: 0x9E/255, green: 0x94/255, blue: 0x88/255))
                        HStack(spacing: 3) {
                            Text("달성")
                                .font(BloomFont.body(11))
                                .foregroundColor(Color(red: 0x9E/255, green: 0x94/255, blue: 0x88/255))
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                                .foregroundColor(.orange)
                        }
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 0) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(doneCount)")
                            .font(BloomFont.serif(36))
                            .foregroundColor(BloomColor.ink)
                        Text("/ \(total)")
                            .font(BloomFont.body(15))
                            .foregroundColor(BloomColor.ink3)
                    }
                    Text("오늘 완료")
                        .font(BloomFont.body(10))
                        .foregroundColor(BloomColor.ink3)
                }
            }
        }
    }
}

struct StoryBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0xFA/255, green: 0xF7/255, blue: 0xF2/255), location: 0),
                    .init(color: Color(red: 0xF3/255, green: 0xEC/255, blue: 0xE1/255), location: 0.5),
                    .init(color: Color(red: 0xEB/255, green: 0xE3/255, blue: 0xD3/255), location: 1),
                ],
                startPoint: UnitPoint(x: 0.15, y: 0),
                endPoint: UnitPoint(x: 0.85, y: 1)
            )

            RadialGradient(
                colors: [Color(red: 1, green: 0xF8/255, blue: 0xE2/255).opacity(0.95), .clear],
                center: UnitPoint(x: 0.5, y: 0),
                startRadius: 0, endRadius: 260
            )

            RadialGradient(
                colors: [Color(red: 0xF0/255, green: 0xE4/255, blue: 0xD0/255).opacity(0.8), .clear],
                center: UnitPoint(x: 0.02, y: 0.85),
                startRadius: 0, endRadius: 220
            )

            RadialGradient(
                colors: [Color(red: 0xEC/255, green: 0xE4/255, blue: 0xD5/255).opacity(0.8), .clear],
                center: UnitPoint(x: 1, y: 0.5),
                startRadius: 0, endRadius: 200
            )

            RadialGradient(
                colors: [Color(red: 1, green: 0xF0/255, blue: 0xBE/255).opacity(0.35), .clear],
                center: UnitPoint(x: 0.5, y: 0.1),
                startRadius: 0, endRadius: 300
            )
            .frame(maxHeight: 280)
            .frame(maxHeight: .infinity, alignment: .top)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
