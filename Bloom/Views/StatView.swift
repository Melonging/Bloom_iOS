import SwiftUI

struct StatView: View {
    @EnvironmentObject var data: AppData

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                weekChart
                monthCard
                rankCard
            }
            .padding(.horizontal, 17.6)
            .padding(.top, 20)
            .padding(.bottom, 80)
        }
    }

    private var weekChart: some View {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let mp = data.mapped
        let total = max(mp.count, 1)
        let week: [(pct: Int, label: String)] = (0...6).reversed().map { i in
            let d = cal.date(byAdding: .day, value: -i, to: now)!
            let k = AppData.dateKey(d)
            let done = (data.logs[k] ?? []).count
            let pct = Int(round(Double(done) / Double(total) * 100))
            let dow = cal.component(.weekday, from: d) - 1
            return (pct, WEEK_DAYS_KO[dow])
        }

        return VStack(alignment: .leading, spacing: 8) {
            sectionLabel("이번 주 달성률")
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<week.count, id: \.self) { i in
                    let w = week[i]
                    VStack(spacing: 4) {
                        Text(w.pct > 0 ? "\(w.pct)%" : "")
                            .font(BloomFont.body(10))
                            .foregroundColor(BloomColor.ink3)
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(w.pct > 0 ? BloomColor.gold : BloomColor.cream3)
                            .frame(height: max(6, CGFloat(w.pct) / 100 * 72))
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: w.pct)
                        Text(w.label)
                            .font(BloomFont.body(11))
                            .foregroundColor(BloomColor.ink3)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 90, alignment: .bottom)
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomCard()
    }

    private var monthCard: some View {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let mp = data.mapped
        var done = 0, total = 0
        for i in 0..<30 {
            let d = cal.date(byAdding: .day, value: -i, to: now)!
            done += (data.logs[AppData.dateKey(d)] ?? []).count
            total += mp.count
        }
        let pct = total > 0 ? Int(round(Double(done) / Double(total) * 100)) : 0
        return VStack(alignment: .leading, spacing: 4) {
            sectionLabel("이번 달 달성률")
            Text("\(pct)%")
                .font(BloomFont.serif(42))
                .foregroundColor(BloomColor.gold)
                .padding(.top, 4)
            Text("최근 30일 기준 · 총 \(done)개 완료")
                .font(BloomFont.body(13))
                .foregroundColor(BloomColor.ink3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomCard()
    }

    private var rankCard: some View {
        let mp = data.mapped
        let counts = data.routineCounts()
        let sorted = mp.sorted { (counts[$0.id] ?? 0) > (counts[$1.id] ?? 0) }

        return VStack(alignment: .leading, spacing: 8) {
            sectionLabel("루틴 순위")
                .padding(.bottom, 4)
            if sorted.isEmpty {
                Text("아직 데이터가 없어요.")
                    .font(BloomFont.body(13))
                    .foregroundColor(BloomColor.ink3)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { i, m in
                        HStack(spacing: 0) {
                            medalView(for: i)
                                .frame(width: 28, alignment: .leading)
                            Image(systemName: m.icon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: m.colorHex))
                                .frame(width: 22)
                                .padding(.trailing, 8)
                            Text(m.name)
                                .font(BloomFont.body(14))
                                .foregroundColor(BloomColor.ink)
                            Spacer()
                            Text("\(counts[m.id] ?? 0)일")
                                .font(BloomFont.body(13, weight: .medium))
                                .foregroundColor(BloomColor.gold)
                        }
                        .padding(.vertical, 10)
                        .overlay(
                            Rectangle()
                                .fill(BloomColor.borderLight)
                                .frame(height: 0.5)
                                .opacity(i == sorted.count - 1 ? 0 : 1),
                            alignment: .bottom
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomCard()
    }

    @ViewBuilder
    private func medalView(for i: Int) -> some View {
        switch i {
        case 0:
            Image(systemName: "trophy.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#E8A020"))   // gold
        case 1:
            Image(systemName: "trophy.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#B8B8B8"))   // silver
        case 2:
            Image(systemName: "trophy.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#C08050"))   // bronze
        default:
            Text("\(i + 1)위")
                .font(BloomFont.body(13, weight: .medium))
                .foregroundColor(BloomColor.ink3)
        }
    }

    private func sectionLabel(_ s: String) -> some View {
        Text(s)
            .font(BloomFont.body(11, weight: .medium))
            .tracking(1.1)
            .foregroundColor(BloomColor.ink3)
            .textCase(.uppercase)
    }
}
