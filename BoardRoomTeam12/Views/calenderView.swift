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

                        VStack(spacing: 8) {
                            Text(vm.weekdayText(for: date))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundColor(.gray)

                            Text(vm.dayNumber(for: date))
                                .font(.system(size: 16, weight: selected ? .bold : .semibold))
                                .foregroundColor(selected ? .white : .primary)
                                .frame(width: 34.95, height: 34.95)
                                .background(
                                    Circle()
                                        .fill(selected ? orange2 : Color.gray.opacity(0.15))
                                )
                        }
                        .id(date)
                        .contentShape(Rectangle())
                        .onTapGesture {
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
                // No centering; today is the first item and should be at the far left by default.
                // If you still want to ensure it's visible after layout, you can scroll to it with a leading anchor:
                // DispatchQueue.main.async { proxy.scrollTo(vm.selectedDate, anchor: .leading) }
            }
        }
    }
}

#Preview {
    CalendarStripView(vm: CalendarStripViewModel())
        .padding()
}
