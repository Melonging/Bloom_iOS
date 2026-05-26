import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var data: AppData
    @State private var slide: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $slide) {
                slide0.tag(0)
                slide1.tag(1)
                slide2.tag(2)
                slide3.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            footer
        }
        .background(BloomColor.warmWhite.ignoresSafeArea())
    }

    private var footer: some View {
        VStack(spacing: 20) {
            HStack(spacing: 6) {
                ForEach(0..<4) { i in
                    Capsule()
                        .fill(i == slide ? BloomColor.gold : BloomColor.border)
                        .frame(width: i == slide ? 22 : 6, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: slide)
                }
            }

            HStack {
                Button(action: finish) {
                    Text("건너뛰기")
                        .font(BloomFont.body(14))
                        .foregroundColor(BloomColor.ink3)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .opacity(slide == 3 ? 0 : 1)

                Spacer()

                Button {
                    if slide >= 3 {
                        finish()
                    } else {
                        withAnimation(.easeInOut(duration: 0.35)) { slide += 1 }
                    }
                } label: {
                    Text(slide == 3 ? "시작하기" : "다음")
                        .font(BloomFont.body(slide == 3 ? 16 : 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, slide == 3 ? 100 : 34)
                        .padding(.vertical, slide == 3 ? 15 : 13)
                        .background(BloomColor.gold)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 20)
        .padding(.bottom, 44)
    }

    private func finish() {
        data.onboarded = true
    }

    // MARK: - Slides

    private var slide0: some View {
        VStack(spacing: 0) {
            Spacer()
            BloomLogoFlower()
                .frame(width: 180, height: 185)
                .padding(.bottom, 28)
            Text("bloom")
                .font(BloomFont.serif(48))
                .foregroundColor(BloomColor.ink)
                .tracking(1.4)
            Text("키링 투두 앱")
                .font(BloomFont.body(11))
                .tracking(2.4)
                .foregroundColor(BloomColor.gold)
                .textCase(.uppercase)
                .padding(.top, 6)
                .padding(.bottom, 16)
            Text("매일 하나씩, 꽃잎이 피어납니다.\n작은 버튼이 당신의 루틴을 만들어요.")
                .font(BloomFont.body(14))
                .foregroundColor(BloomColor.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .frame(maxWidth: 280)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var slide1: some View {
        VStack(spacing: 0) {
            Spacer()
            KeyringArt()
                .frame(width: 130, height: 210)
                .padding(.bottom, 28)
            Text("7개의 버튼,\n7가지 나만의 루틴")
                .font(BloomFont.serif(25))
                .foregroundColor(BloomColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 12)
            Text("물리적인 키링에 달린 버튼을 누르면\n할 일이 자동으로 체크돼요.")
                .font(BloomFont.body(14))
                .foregroundColor(BloomColor.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var slide2: some View {
        VStack(spacing: 0) {
            Spacer()
            MappingArt()
                .frame(width: 286, height: 148)
                .padding(.bottom, 28)
            Text("버튼 하나에\n할 일 하나")
                .font(BloomFont.serif(25))
                .foregroundColor(BloomColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 12)
            Text("매핑 탭에서 각 버튼에 원하는\n이름·아이콘·색상을 자유롭게 설정해요.")
                .font(BloomFont.body(14))
                .foregroundColor(BloomColor.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    private var slide3: some View {
        VStack(spacing: 0) {
            Spacer()
            SmallFlower()
                .frame(width: 180, height: 80)
                .padding(.bottom, 28)
            Text("오늘부터,\n매일 피워봐요")
                .font(BloomFont.serif(28))
                .foregroundColor(BloomColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 12)
            Text("모든 할 일을 완료하면\n꽃이 활짝 피어납니다")
                .font(BloomFont.body(14))
                .foregroundColor(BloomColor.ink2)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

// MARK: - Onboarding art

private struct BloomLogoFlower: View {
    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width, H = geo.size.height
            let cx = W / 2, cy = H / 2 - 5
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: cx, y: cy + 23))
                    p.addLine(to: CGPoint(x: cx, y: cy + 82))
                }
                .stroke(Color(red: 0xCD/255, green: 0xC4/255, blue: 0xB6/255),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round))

                Ellipse()
                    .fill(Color(red: 0x7A/255, green: 0x8F/255, blue: 0x5A/255))
                    .frame(width: 24, height: 13)
                    .rotationEffect(.degrees(-32))
                    .position(x: cx - 16, y: cy + 57)
                Ellipse()
                    .fill(Color(red: 0x8A/255, green: 0x9F/255, blue: 0x68/255))
                    .frame(width: 24, height: 13)
                    .rotationEffect(.degrees(32))
                    .position(x: cx + 16, y: cy + 68)

                let petalPositions: [(CGFloat, CGFloat, Double)] = [
                    (0, -44, 0), (35, -27, 51), (43, 10, 103), (19, 40, 154),
                    (-19, 40, 206), (-43, 10, 257), (-35, -27, 309),
                ]
                ForEach(0..<7, id: \.self) { i in
                    let p = petalPositions[i]
                    Ellipse()
                        .fill(RadialGradient(
                            colors: [.white,
                                     Color(red: 0xF8/255, green: 0xF3/255, blue: 0xEC/255),
                                     Color(red: 0xE8/255, green: 0xE0/255, blue: 0xD2/255)],
                            center: UnitPoint(x: 0.38, y: 0.25),
                            startRadius: 0, endRadius: 28))
                        .overlay(Ellipse().strokeBorder(
                            Color(red: 0xF0/255, green: 0xE8/255, blue: 0xDC/255), lineWidth: 0.5))
                        .frame(width: 28, height: 44)
                        .rotationEffect(.degrees(p.2))
                        .position(x: cx + p.0, y: cy + p.1)
                }

                Circle()
                    .fill(RadialGradient(
                        colors: [Color(red: 0xF5/255, green: 0xC8/255, blue: 0x4A/255),
                                 Color(red: 0xC8/255, green: 0x80/255, blue: 0x10/255)],
                        center: UnitPoint(x: 0.45, y: 0.35),
                        startRadius: 0, endRadius: 30))
                    .overlay(Circle().strokeBorder(Color(red: 0xC8/255, green: 0x90/255, blue: 0x20/255), lineWidth: 0.8))
                    .frame(width: 46, height: 46)
                    .position(x: cx, y: cy)
                Text("bloom")
                    .font(BloomFont.body(10, weight: .medium))
                    .foregroundColor(Color(red: 0x7A/255, green: 0x60/255, blue: 0x30/255))
                    .position(x: cx, y: cy + 1)
            }
        }
    }
}

private struct KeyringArt: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Ellipse()
                    .strokeBorder(Color(red: 0xC0/255, green: 0xA0/255, blue: 0x70/255).opacity(0.9), lineWidth: 5.5)
                    .frame(width: 36, height: 28)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0xC8/255, green: 0xA8/255, blue: 0x70/255))
                    .frame(width: 16, height: 22)
                    .offset(y: -3)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 5)

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(red: 0xF5/255, green: 0xED/255, blue: 0xD8/255))
                    .overlay(RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color(red: 0xE0/255, green: 0xD4/255, blue: 0xBC/255), lineWidth: 1.5))
                    .frame(width: 102, height: 150)
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color(red: 0xFB/255, green: 0xF7/255, blue: 0xEF/255), lineWidth: 1.5)
                    .frame(width: 92, height: 140)
                Text("bloom")
                    .font(BloomFont.serif(8))
                    .tracking(1.7)
                    .foregroundColor(Color(red: 0xC8/255, green: 0xA8/255, blue: 0x70/255))
                    .offset(y: -55)

                ForEach(0..<7, id: \.self) { i in
                    keyringButton(i)
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
    }

    @ViewBuilder
    private func keyringButton(_ i: Int) -> some View {
        let positions: [(x: CGFloat, y: CGFloat, r: CGFloat, fill: Color, symbol: String, size: CGFloat)] = [
            (x: -27, y: -22,  r: 19, fill: Color(hex: "#E8A020"), symbol: "figure.run",           size: 16),
            (x:  27, y: -22,  r: 19, fill: Color(hex: "#5A7A8F"), symbol: "drop.fill",            size: 16),
            (x: -44, y:  22,  r: 16, fill: Color(hex: "#8B6F52"), symbol: "book.fill",            size: 13),
            (x:   0, y:  22,  r: 16, fill: Color(hex: "#7A8F5A"), symbol: "figure.mind.and.body", size: 13),
            (x:  44, y:  22,  r: 16, fill: Color(hex: "#C8546A"), symbol: "pills.fill",           size: 13),
            (x: -27, y:  60,  r: 14, fill: Color(hex: "#A67C52"), symbol: "leaf.fill",            size: 12),
            (x:  27, y:  60,  r: 14, fill: Color(hex: "#9E9488"), symbol: "pencil",               size: 12),
        ]
        let p = positions[i]
        ZStack {
            Circle().fill(p.fill.opacity(0.9))
                .frame(width: p.r * 2, height: p.r * 2)
            Image(systemName: p.symbol)
                .font(.system(size: p.size, weight: .medium))
                .foregroundColor(.white)
        }
        .offset(x: p.x, y: p.y)
    }
}

private struct MappingArt: View {
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { row in
                mapRow(row)
            }
        }
    }

    @ViewBuilder
    private func mapRow(_ row: Int) -> some View {
        let yOffset = CGFloat(row) * 50 - 50
        let items: [(symbol: String, fill: Color, label: String, labelBg: Color, labelStroke: Color, labelFg: Color)] = [
            ("figure.run", Color(hex: "#E8A020"), "아침 운동", Color(hex: "#FFF8EE"), Color(hex: "#EDD090"), Color(hex: "#5A3E10")),
            ("drop.fill",  Color(hex: "#5A7A8F"), "물 마시기", Color(hex: "#EEF4F8"), Color(hex: "#9ABECE"), Color(hex: "#2A4E60")),
            ("book.fill",  Color(hex: "#8B6F52"), "독서 30분", Color(hex: "#F5EFE8"), Color(hex: "#CCAA88"), Color(hex: "#4A2E10")),
        ]
        let item = items[row]
        HStack(spacing: 0) {
            ZStack {
                Circle().fill(item.fill.opacity(0.9)).frame(width: 44, height: 44)
                Image(systemName: item.symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }

            ZStack {
                ArrowDashed()
                    .stroke(Color(red: 0xD4/255, green: 0xC8/255, blue: 0xB0/255),
                            style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(red: 0xD4/255, green: 0xC8/255, blue: 0xB0/255))
                    .offset(x: 24)
            }
            .frame(width: 50, height: 28)

            Text(item.label)
                .font(BloomFont.body(13))
                .foregroundColor(item.labelFg)
                .frame(width: 116, height: 28)
                .background(item.labelBg)
                .overlay(Capsule().strokeBorder(item.labelStroke, lineWidth: 1))
                .clipShape(Capsule())
        }
        .offset(y: yOffset)
    }
}

private struct ArrowDashed: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: 0, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX - 6, y: rect.midY))
        return p
    }
}

private struct SmallFlower: View {
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width / 2, cy = geo.size.height / 2
            ZStack {
                ForEach(0..<7, id: \.self) { i in
                    let positions: [(CGFloat, CGFloat, Double)] = [
                        (0, -32, 0), (26, -20, 51), (31, 8, 103), (14, 30, 154),
                        (-14, 30, 206), (-31, 8, 257), (-26, -20, 309),
                    ]
                    let p = positions[i]
                    Ellipse()
                        .fill(RadialGradient(
                            colors: [Color(red: 1, green: 0xF0/255, blue: 0xC0/255),
                                     Color(red: 0xE8/255, green: 0xA0/255, blue: 0x20/255)],
                            center: UnitPoint(x: 0.38, y: 0.25),
                            startRadius: 0, endRadius: 22))
                        .frame(width: 22, height: 34)
                        .rotationEffect(.degrees(p.2))
                        .position(x: cx + p.0, y: cy + p.1)
                }
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(red: 0xF5/255, green: 0xC8/255, blue: 0x4A/255),
                                 Color(red: 0xC8/255, green: 0x80/255, blue: 0x10/255)],
                        center: UnitPoint(x: 0.45, y: 0.35),
                        startRadius: 0, endRadius: 22))
                    .frame(width: 34, height: 34)
                    .position(x: cx, y: cy)
            }
        }
    }
}
