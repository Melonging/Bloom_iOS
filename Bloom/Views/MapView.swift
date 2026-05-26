import SwiftUI

struct MapView: View {
    @EnvironmentObject var data: AppData
    @State private var editingId: Int? = nil
    @State private var draft: Mapping = Mapping(id: -1, name: "", icon: "", colorHex: "#E8A020")

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("bloom 키링의 7개 버튼에 각각 할 일을 연결하세요.\n슬롯을 탭하면 이름·아이콘·색상을 수정할 수 있어요.")
                    .font(BloomFont.body(13))
                    .foregroundColor(BloomColor.ink3)
                    .lineSpacing(4)
                    .padding(.bottom, 8)

                ForEach(Array(data.mappings.enumerated()), id: \.element.id) { i, m in
                    VStack(spacing: 0) {
                        slotRow(index: i, m: m)
                        if editingId == m.id {
                            editPanel
                                .padding(.top, 10)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
            .padding(.horizontal, 17.6)
            .padding(.top, 20)
            .padding(.bottom, 80)
        }
    }

    private func slotRow(index: Int, m: Mapping) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if editingId == m.id {
                    editingId = nil
                } else {
                    editingId = m.id
                    draft = m
                }
            }
        } label: {
            HStack(spacing: 12) {
                Text("\(index + 1)")
                    .font(BloomFont.body(11, weight: .medium))
                    .foregroundColor(BloomColor.ink3)
                    .frame(width: 22, height: 22)
                    .background(BloomColor.cream2)
                    .clipShape(Circle())

                Image(systemName: m.icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(hex: m.colorHex))
                    .frame(width: 36, height: 36)
                    .background(Color(hex: m.colorHex).opacity(0.13))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 1) {
                    Text(m.name.isEmpty ? "(미설정)" : m.name)
                        .font(BloomFont.body(14, weight: .medium))
                        .foregroundColor(BloomColor.ink)
                    Text("버튼 \(index + 1)")
                        .font(BloomFont.body(12))
                        .foregroundColor(BloomColor.ink3)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(BloomColor.ink3)
                    .rotationEffect(.degrees(editingId == m.id ? 90 : 0))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(BloomColor.warmWhite)
            .overlay(
                RoundedRectangle(cornerRadius: BloomRadius.rSm)
                    .strokeBorder(BloomColor.border, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: BloomRadius.rSm))
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
    }

    private var editPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("할 일 이름")
                .font(BloomFont.body(12, weight: .medium))
                .foregroundColor(BloomColor.ink2)
            TextField("이름", text: $draft.name)
                .font(BloomFont.body(14))
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(BloomColor.warmWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: BloomRadius.rSm)
                        .strokeBorder(BloomColor.border, lineWidth: 0.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: BloomRadius.rSm))

            Text("아이콘")
                .font(BloomFont.body(12, weight: .medium))
                .foregroundColor(BloomColor.ink2)

            FlowLayout(spacing: 6) {
                ForEach(BLOOM_ICONS, id: \.self) { ic in
                    Button {
                        draft.icon = ic
                    } label: {
                        Image(systemName: ic)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(draft.icon == ic ? BloomColor.gold : BloomColor.ink2)
                            .frame(width: 38, height: 38)
                            .background(draft.icon == ic
                                        ? Color(red: 1, green: 0xF8/255, blue: 0xEC/255)
                                        : BloomColor.warmWhite)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        draft.icon == ic ? BloomColor.gold : BloomColor.border,
                                        lineWidth: draft.icon == ic ? 2 : 0.5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("컬러")
                .font(BloomFont.body(12, weight: .medium))
                .foregroundColor(BloomColor.ink2)

            HStack(spacing: 8) {
                ForEach(BLOOM_COLOR_HEX, id: \.self) { hex in
                    Button { draft.colorHex = hex } label: {
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        draft.colorHex == hex ? BloomColor.ink : .clear,
                                        lineWidth: 2.5)
                            )
                            .scaleEffect(draft.colorHex == hex ? 1.1 : 1)
                            .animation(.easeInOut(duration: 0.15), value: draft.colorHex)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                data.update(mapping: draft)
                withAnimation { editingId = nil }
            } label: {
                Text("저장")
                    .font(BloomFont.body(14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 11)
                    .background(BloomColor.gold)
                    .clipShape(RoundedRectangle(cornerRadius: BloomRadius.rSm))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(BloomColor.cream2)
        .overlay(
            RoundedRectangle(cornerRadius: BloomRadius.rSm)
                .strokeBorder(BloomColor.border, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: BloomRadius.rSm))
        .padding(.bottom, 8)
    }
}

/// Minimal flow layout for icon grid.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxW {
                x = 0
                y += rowH + spacing
                rowH = 0
            }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: maxW, height: y + rowH)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX {
                x = bounds.minX
                y += rowH + spacing
                rowH = 0
            }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}
