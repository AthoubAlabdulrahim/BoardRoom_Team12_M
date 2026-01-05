import SwiftUI
import Combine

struct RoomDetailView: View {

    let roomRecord: BoardRoom
    let existingBooking: Booking?
    let roomBookings: [Booking]
    

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RoomDetailViewModel()
    @State private var navigateToSuccess = false
    @State private var successType: BookingActionType = .created
    @State private var successDateText: String = ""


    private var selectedTS: Int { viewModel.calendarVM.selectedUnixTimestamp }

    // ✅ For new booking: just need a valid available date
    private var canCreate: Bool {
        viewModel.calendarVM.isAvailable(viewModel.calendarVM.selectedDate)
    }

    // ✅ For update: allow update only if date actually changed (you can remove this condition if you want)
    private var canUpdate: Bool {
        guard let existing = existingBooking else { return false }
        return viewModel.calendarVM.isAvailable(viewModel.calendarVM.selectedDate) && selectedTS != normalize(existing.fields.date)
    }

    private func normalize(_ ts: Int) -> Int {
        let seconds: TimeInterval
        if ts > 2_000_000_000_000 { seconds = TimeInterval(ts) / 1000.0 } else { seconds = TimeInterval(ts) }
        let d = Date(timeIntervalSince1970: seconds)
        return Int(Calendar.current.startOfDay(for: d).timeIntervalSince1970)
    }

    var body: some View {

        let deviceWidth = min(UIScreen.main.bounds.width, 430)
        let bannerHeight = deviceWidth * 0.72
        let gradientHeight: CGFloat = 84
        let horizontalPadding: CGFloat = 12

        VStack(spacing: 0) {

            CustomNavBar(
                title: roomRecord.fields.name,
                onBack: { dismiss() }
            )

            GeometryReader { geo in
                let bottomInset = geo.safeAreaInsets.bottom

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {

                        ZStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: roomRecord.fields.imageURL)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(height: bannerHeight)
                            .clipped()

                            LinearGradient(
                                colors: [.clear, .white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: gradientHeight)

                            HStack {
                                Label("Floor \(roomRecord.fields.floorNo)", systemImage: "paperplane")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color(red: 35/255, green: 36/255, blue: 85/255))

                                Spacer()

                                Label("\(roomRecord.fields.seatNo)", systemImage: "person.2")
                                    .font(AppFont.caption)
                                    .foregroundColor(.orange)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.bottom, 8)
                        }

                        Text("Description")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal, horizontalPadding)

                        Text(roomRecord.fields.description)
                            .font(AppFont.body)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, horizontalPadding)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Facilities")
                                .font(AppFont.sectionTitle)
                                .padding(.horizontal, horizontalPadding)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(roomRecord.fields.facilities, id: \.self) { facility in
                                        FacilityChip(
                                            customIconName: iconName(for: facility),
                                            title: facility
                                        )
                                    }
                                }
                                .padding(.horizontal, horizontalPadding)
                            }
                        }

                        Text("Select a date")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal, horizontalPadding)

                        CalendarStripView(vm: viewModel.calendarVM)
                            .padding(.bottom, 4)

                        actionButtons
                    }
                    .padding(.top, 8)
                    .padding(.bottom, max(8, bottomInset))
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToSuccess) {
            SuccessView(
                  type: successType,
                  roomName: roomRecord.fields.name,
                  dateText: successDateText
              )
              .onDisappear { dismiss() }
        }
        .onAppear {
            let booked = roomBookings.map { $0.fields.date }
                let allow = existingBooking?.fields.date

                // ✅ 1) Preselect existing booking date FIRST
                if let b = existingBooking {
                    viewModel.calendarVM.forceSelect(dateFromUnix(b.fields.date))
                }

                // ✅ 2) Then apply availability (so selected date is evaluated correctly)
                viewModel.setup(bookedTimestamps: booked, allowTimestamp: allow)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {

            if let booking = existingBooking {

                Button("Update Booking") {
                    Task {
                        do {
                                   try await viewModel.updateBooking(booking: booking, roomID: roomRecord.id)
                                   successType = .updated
                                   successDateText = formatBookingDate(selectedTS)
                                   navigateToSuccess = true
                               } catch {
                                   print("❌ Update failed:", error.localizedDescription)
                               }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: canUpdate))
                .disabled(!canUpdate)
                .opacity(canUpdate ? 1 : 0.6)

                Button("Delete Booking") {
                    Task {
                        do {
                                   try await viewModel.deleteBooking(booking: booking)
                                   successType = .deleted
                                   successDateText = formatBookingDate(booking.fields.date)
                                   navigateToSuccess = true
                               } catch {
                                   print("❌ Delete failed:", error.localizedDescription)
                               }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: true))

            } else {

                Button("Book Now") {
                    Task {
                        do {
                                   try await viewModel.createBooking(roomID: roomRecord.id)
                                   successType = .created
                                   successDateText = formatBookingDate(selectedTS)
                                   navigateToSuccess = true
                               } catch {
                                   print("❌ Booking failed:", error.localizedDescription)
                               }
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: canCreate))
                .disabled(!canCreate)
                .opacity(canCreate ? 1 : 0.6)
            }

        }
        .padding(.horizontal, 12)
        .padding(.top, 4)
    }

    private func formatBookingDate(_ timestamp: Int) -> String {
        let seconds: TimeInterval = timestamp > 2_000_000_000_000 ? TimeInterval(timestamp) / 1000.0 : TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: seconds)
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "EEEE, d MMMM yyyy"
        return output.string(from: date)
    }

    private func iconName(for facility: String) -> String {
        switch facility {
        case "Wi-Fi": return "wifi"
        case "Screen": return "tv"
        case "Microphone": return "mic"
        case "Projector": return "videoprojector"
        default: return "star"
        }
    }
    private func dateFromUnix(_ ts: Int) -> Date {
        let seconds: TimeInterval = ts > 2_000_000_000_000 ? TimeInterval(ts) / 1000.0 : TimeInterval(ts)
        return Date(timeIntervalSince1970: seconds)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color(red: 212/255, green: 94/255, blue: 57/255))
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
