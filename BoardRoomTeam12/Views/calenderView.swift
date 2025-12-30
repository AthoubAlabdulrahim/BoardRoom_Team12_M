import SwiftUI

struct CalendarStripView: View {
    @ObservedObject var vm: CalendarStripViewModel

    private let orange2 = Color("orange2")

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(vm.days, id: \.self) { date in
                        let selected = vm.isSelected(date)
                        let available = vm.isAvailable(date)

                        VStack(spacing: 8) {
                            Text(vm.weekdayText(for: date))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)

                            Text(vm.dayNumber(for: date))
                                .font(.system(size: 16, weight: selected ? .bold : .semibold))
                                .foregroundColor(available ? (selected ? .white : .primary) : .white)
                                .frame(width: 34.95, height: 34.95)
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
            }
            .onAppear {
                // If needed, you can ensure current selection is visible:
                // DispatchQueue.main.async { proxy.scrollTo(vm.selectedDate, anchor: .center) }
            }
        }
    }
}

#Preview {
    CalendarStripView(vm: CalendarStripViewModel())
        .padding()
}
