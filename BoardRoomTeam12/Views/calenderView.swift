import SwiftUI

struct CalendarStripView: View {
    @ObservedObject var vm: CalendarStripViewModel

    private let orange = Color(red: 0.78, green: 0.41, blue: 0.29) // close to your design

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
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(selected ? orange : Color.gray.opacity(0.15))
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
                // Center the initial selected day
                DispatchQueue.main.async {
                    proxy.scrollTo(vm.selectedDate, anchor: .center)
                }
            }
        }
    }
}
