import SwiftUI

struct CalendarStripView: View {
    @ObservedObject var vm: CalendarStripViewModel

    private let orange2 = Color("orange2")

    var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width, 430)
            let circleSize = max(32, min(40, width * 0.08))
            let hSpacing: CGFloat = 14

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: hSpacing) {
                    ForEach(vm.days, id: \.self) { date in
                        let selected = vm.isSelected(date)
                        let available = vm.isAvailable(date)

                        VStack(spacing: 8) {
                            Text(vm.weekdayText(for: date))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)

                            Text(vm.dayNumber(for: date))
                                .font(.system(size: selected ? 17 : 16, weight: selected ? .bold : .semibold))
                                .foregroundColor(textColor(available: available, selected: selected))
                                .frame(width: circleSize, height: circleSize)
                                .background(Circle().fill(bgColor(available: available, selected: selected)))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            guard available else { return }
                            withAnimation(.easeInOut) { vm.select(date) }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 72)
    }

    private func textColor(available: Bool, selected: Bool) -> Color {
        if !available { return Color(.systemGray2) }     // ✅ silver-ish
        if selected { return .white }
        return Color("blue2")
    }

    private func bgColor(available: Bool, selected: Bool) -> Color {
        if !available { return Color(.systemGray4) }     // ✅ silver background
        if selected { return orange2 }
        return Color.gray.opacity(0.15)
    }
}
