import SwiftUI

enum BloomTab: String, CaseIterable, Identifiable {
    case home, map, log, stat
    var id: String { rawValue }
    var label: String {
        switch self {
        case .home: return "홈"
        case .map:  return "매핑"
        case .log:  return "기록"
        case .stat: return "통계"
        }
    }
}

struct ContentView: View {
    @StateObject private var data = AppData()
    @State private var tab: BloomTab = .home
    @State private var showReview = false

    var body: some View {
        ZStack {
            BloomColor.warmWhite.ignoresSafeArea()

            VStack(spacing: 0) {
                if tab != .home { mainHeader }
                tabsBar
                contentArea
            }
            .background(tab == .home ? Color.clear : BloomColor.warmWhite)

            if !data.onboarded {
                OnboardingView()
                    .environmentObject(data)
                    .transition(.opacity)
                    .zIndex(100)
            }

            if showReview {
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showReview = false } }
                    .zIndex(80)
                VStack {
                    Spacer()
                    WeeklyReviewSheet(onClose: { withAnimation { showReview = false } })
                        .environmentObject(data)
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.93)
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(90)
            }
        }
        .environmentObject(data)
        .animation(.easeInOut(duration: 0.3), value: tab)
        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: showReview)
        .animation(.easeInOut(duration: 0.3), value: data.onboarded)
    }

    private var mainHeader: some View {
        let cal = Calendar(identifier: .gregorian)
        let now = Date()
        let y = cal.component(.year, from: now)
        let m = cal.component(.month, from: now)
        let d = cal.component(.day, from: now)
        let dow = cal.component(.weekday, from: now) - 1
        return VStack(alignment: .leading, spacing: 3) {
            Text("bloom")
                .font(BloomFont.serif(11))
                .tracking(3.3)
                .foregroundColor(BloomColor.ink3)
                .textCase(.lowercase)
            Text("\(y)년 \(m)월 \(d)일 \(WEEK_DAYS_KO[dow])요일")
                .font(BloomFont.serif(22))
                .foregroundColor(BloomColor.ink)
            Text("오늘의 기록")
                .font(BloomFont.body(12))
                .foregroundColor(BloomColor.ink3)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 0)
    }

    private var tabsBar: some View {
        HStack(spacing: 0) {
            ForEach(BloomTab.allCases) { t in
                Button { tab = t } label: {
                    VStack(spacing: 6) {
                        Text(t.label)
                            .font(BloomFont.body(13, weight: .medium))
                            .tracking(0.4)
                            .foregroundColor(tabFgColor(t))
                        Rectangle()
                            .fill(tab == t ? BloomColor.gold : Color.clear)
                            .frame(height: 2)
                    }
                    .padding(.top, 11)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .background(tab == .home ? Color.clear : BloomColor.warmWhite)
        .overlay(
            Rectangle()
                .fill(tab == .home ? Color.clear : BloomColor.border)
                .frame(height: 0.5),
            alignment: .bottom
        )
        .padding(.top, tab == .home ? 0 : 18)
        .zIndex(20)
    }

    private func tabFgColor(_ t: BloomTab) -> Color {
        if tab == t {
            return tab == .home ? Color(red: 0x2E/255, green: 0x28/255, blue: 0x20/255) : BloomColor.ink
        }
        return tab == .home ? Color(red: 0x50/255, green: 0x3C/255, blue: 0x1E/255).opacity(0.4) : BloomColor.ink3
    }

    @ViewBuilder
    private var contentArea: some View {
        switch tab {
        case .home: HomeView().environmentObject(data)
        case .map:  MapView().environmentObject(data)
        case .log:  LogView(showReview: $showReview).environmentObject(data)
        case .stat: StatView().environmentObject(data)
        }
    }
}

#Preview {
    ContentView()
}
