import SwiftUI

struct CalendarCircleView: View {

    let model: BookingDate
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {

            Text(model.day)
                .font(AppFont.caption)
                .foregroundColor(.gray)

            ZStack {
                Circle()
                    .fill(circleColor)
                    .frame(width: 44, height: 44)

                Text(model.date)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(textColor)
            }
        }
    }

    private var circleColor: Color {
        if !model.isAvailable {
            return Color.gray.opacity(0.6)
        }
        return isSelected ? Color(red: 212/255, green: 94/255, blue: 57/255) : Color.white
    }

    private var textColor: Color {
        if !model.isAvailable {
            return .white
        }
        return isSelected ? .white : .primary
    }
}
