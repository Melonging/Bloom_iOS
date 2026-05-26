import SwiftUI

struct LogView: View {
    @EnvironmentObject var data: AppData
    @Binding var showReview: Bool
    @State private var confirmReset = false
    @State private var resetDone = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                reviewLink
                streakCard
                dotGridCard
                todayCard
                resetCard
            }
            .padding(.horizontal, 17.6)
            .padding(.top, 20)
            .padding(.bottom, 80)
        }
        .alert("오늘의 기록을 저장하고 초기화할까요?", isPresented: $confirmReset) {
            Button("취소", role: .cancel) {}
            Button("초기화") {
                data.resetToday()
                resetDone = true
            }
        }
        .alert("오늘 하루 수고했어요!\n내일 또 피워봐요.", isPresented: $resetDone) {
            Button("확인", role: .cancel) {}
        }
    }

    private var reviewLink: some View {
        let pct = data.weekData().pct
        return Button { showReview = true } label: {
            HStack(spacing: 11) {
                Circle()
                    .fill(BloomColor.gold)
                    .frame(width: 7, height: 7)
                    .shadow(color: BloomColor.gold.opacity(0.8), radius: 4)
                VStack(alignment: .leading, spacing: 2) {
                    Text("이번 주 리뷰 보기")
                        .font(BloomFont.body(14, weight: .medium))
                        .foregroundColor(BloomColor.gold)
                    Text("이번 주 달성률 \(pct)%")
                        .font(BloomFont.body(11))
                        .foregroundColor(BloomColor.gold.opacity(0.4))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .light))
                    .foregroundColor(BloomColor.gold.opacity(0.4))
            }
            .padding(.horizontal, 19).padding(.vertical, 17)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0x1E/255, green: 0x16/255, blue: 0x10/255),
                        Color(red: 0x2A/255, green: 0x1E/255, blue: 0x14/255),
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: BloomRadius.r)
                    .strokeBorder(BloomColor.gold.opacity(0.32), lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: BloomRadius.r))
        }
        .buttonStyle(.plain)
    }

    private var streakCard: some View {
        let streak = data.streakCount()
        let desc: String =
            streak >= 7 ? "일주일 연속 달성! 대단해요" :
            streak >= 3 ? "잘 하고 있어요, 계속 유지해봐요" :
                          "매일 조금씩 쌓아가요"
        return VStack(alignment: .leading, spacing: 6) {
            sectionLabel("연속 기록")
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(streak)").font(BloomFont.serif(52)).foregroundColor(BloomColor.gold)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("일 연속 달성")
                        .font(BloomFont.body(16))
                        .foregroundColor(BloomColor.ink2)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            }
            .padding(.top, 6)
            Text(desc).font(BloomFont.body(13)).foregroundColor(BloomColor.ink3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomCard()
    }

    private var dotGridCard: some View {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let mp = data.mapped
        return VStack(alignment: .leading, spacing: 8) {
            sectionLabel("최근 30일")
            Text("진할수록 달성률이 높은 날이에요")
                .font(BloomFont.body(12))
                .foregroundColor(BloomColor.ink3)
            FlowLayout(spacing: 5) {
                ForEach((0...29).reversed(), id: \.self) { i in
                    let d = cal.date(byAdding: .day, value: -i, to: now)!
                    let k = AppData.dateKey(d)
                    let done = (data.logs[k] ?? []).count
                    let total = max(mp.count, 1)
                    let pct = Double(done) / Double(total)
                    let (bg, fc) = dotColors(pct: pct)
                    Text("\(cal.component(.day, from: d))")
                        .font(BloomFont.body(9, weight: .medium))
                        .foregroundColor(fc)
                        .frame(width: 26, height: 26)
                        .background(bg)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomCard()
    }

    private func dotColors(pct: Double) -> (Color, Color) {
        if pct >= 1 { return (BloomColor.gold, .white) }
        if pct >= 0.7 { return (Color(hex: "#F0C850"), Color(hex: "#7A5010")) }
        if pct >= 0.4 { return (Color(hex: "#F5D880"), Color(hex: "#8B6830")) }
        if pct > 0    { return (Color(hex: "#F0EAD0"), Color(hex: "#A89860")) }
        return (Color(hex: "#F0EBE2"), Color(hex: "#C0B8AD"))
    }

    private var todayCard: some View {
        let mp = data.mapped
        let td = data.todaySet
        return VStack(alignment: .leading, spacing: 8) {
            sectionLabel("오늘 완료")
            if mp.isEmpty {
                Text("매핑된 할 일이 없어요.")
                    .font(BloomFont.body(13))
                    .foregroundColor(BloomColor.ink3)
                    .padding(.vertical, 10)
            } else {
                VStack(spacing: 8) {
                    ForEach(mp) { m in
                        let isDone = td.contains(m.id)
                        HStack(spacing: 10) {
                            Image(systemName: m.icon)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(hex: m.colorHex))
                                .frame(width: 22)
                            Text(m.name)
                                .font(BloomFont.body(14))
                                .strikethrough(isDone, color: BloomColor.ink3)
                                .foregroundColor(isDone ? BloomColor.ink3 : BloomColor.ink)
                            Spacer()
                            Text(isDone ? "완료" : "미완")
                                .font(BloomFont.body(11, weight: .medium))
                                .foregroundColor(isDone
                                    ? Color(hex: "#C88010")
                                    : Color(hex: "#B0AB9F"))
                                .padding(.horizontal, 9).padding(.vertical, 3)
                                .background(isDone ? Color(hex: "#FFF0D0") : Color(hex: "#F2EDE5"))
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 13).padding(.vertical, 12)
                        .background(isDone ? BloomColor.cream2 : BloomColor.warmWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: BloomRadius.rSm)
                                .strokeBorder(BloomColor.border, lineWidth: 0.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: BloomRadius.rSm))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomCard()
    }

    private var resetCard: some View {
        VStack(spacing: 8) {
            Text("하루 마무리")
                .font(BloomFont.serif(20))
                .foregroundColor(BloomColor.ink)
            Text("오늘의 기록을 저장하고\n내일을 위해 초기화합니다.")
                .font(BloomFont.body(13))
                .foregroundColor(BloomColor.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Button { confirmReset = true } label: {
                Text("오늘 마무리하기")
                    .font(BloomFont.body(14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 11)
                    .background(BloomColor.gold)
                    .clipShape(RoundedRectangle(cornerRadius: BloomRadius.rSm))
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22).padding(.horizontal, 22)
        .background(
            LinearGradient(
                colors: [BloomColor.cream, BloomColor.cream2],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: BloomRadius.r)
                .strokeBorder(BloomColor.border, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: BloomRadius.r))
    }

    private func sectionLabel(_ s: String) -> some View {
        Text(s)
            .font(BloomFont.body(11, weight: .medium))
            .tracking(1.1)
            .foregroundColor(BloomColor.ink3)
            .textCase(.uppercase)
    }
}
