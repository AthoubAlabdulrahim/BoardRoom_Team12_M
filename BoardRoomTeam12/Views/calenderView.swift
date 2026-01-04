import SwiftUI

struct CalendarStripView: View {
    @ObservedObject var vm: CalendarStripViewModel

    private let orange2 = Color("orange2")

    var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width, 430)
            let circleSize = max(32, min(40, width * 0.08)) // scales with device width
            let hSpacing: CGFloat = 14

            ScrollViewReader { proxy in
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
                                    .foregroundColor(available ? (selected ? .white : .primary) : .white)
                                    .frame(width: circleSize, height: circleSize)
                                    .background(
                                        Circle()
                                            .fill(
                                                available
                                                ? (selected ? orange2 : Color.gray.opacity(0.15))
                                                : Color.gray.opacity(0.6)
                                            )
                                    )
                            }
                            .id(date)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                guard available else { return }
                                withAnimation(.easeInOut) {
                                    vm.select(date)
                                    proxy.scrollTo(date, anchor: .center)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onAppear {
                    // Optionally center the selected date
                    // DispatchQueue.main.async { proxy.scrollTo(vm.selectedDate, anchor: .center) }
                }
            }
        }
        .frame(height: 72) // enough to contain weekday + circle
    }
}

#Preview {
    CalendarStripView(vm: CalendarStripViewModel())
        .padding()
}
