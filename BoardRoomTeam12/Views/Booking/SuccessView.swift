import SwiftUI

enum BookingActionType {
    case created
    case updated
    case deleted

    var title: String {
        switch self {
        case .created: return "Booking Success!"
        case .updated: return "Booking Updated!"
        case .deleted: return "Booking Deleted!"
        }
    }

    func message(roomName: String, dateText: String) -> String {
        switch self {
        case .created:
            return "Your booking for \(roomName) on \(dateText) is confirmed."
        case .updated:
            return "Your booking for \(roomName) has been updated to \(dateText)."
        case .deleted:
            return "Your booking for \(roomName) on \(dateText) has been deleted."
        }
    }
}

struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss

    let type: BookingActionType
    let roomName: String
    let dateText: String

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                Image("backgroundLines")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()

                Image("CircleIcon")
                    .resizable()
                    .frame(width: 253, height: 253)
                    .offset(y: 60)
            }
            .padding(.bottom, 20)

            Text(type.title)
                .font(.largeTitle.bold())
                .foregroundColor(Color(red: 33/255, green: 38/255, blue: 82/255))
                .padding(.bottom, 15)

            Text(type.message(roomName: roomName, dateText: dateText))
                .font(.footnote.bold())
                .foregroundColor(Color("blue2"))
                .multilineTextAlignment(.center)
                .frame(width: 358, height: 69)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 6)
                .padding(.bottom, 40)

            Spacer()

            Button(action: { dismiss() }) {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 191/255, green: 93/255, blue: 49/255))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .top)
        .background(Color(red: 0.953, green: 0.953, blue: 0.953))
        .ignoresSafeArea()
    }
}
