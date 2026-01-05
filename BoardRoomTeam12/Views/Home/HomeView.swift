import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = BookingViewModel()
    @StateObject private var calendarVM = CalendarStripViewModel()
    @State private var refreshToken = UUID()
    @State private var selectedRoomID: String? = nil

    var body: some View {
        NavigationStack {
            GeometryReader { geo in

                let width = max(min(geo.size.width, 430), 1)
                let topBarHeight: CGFloat = 52
                let bannerWidth = max(width - 32, 1)
                let bannerHeight = bannerWidth * 0.385
                let cardImageSize: CGFloat = 80

                VStack(spacing: 0) { 

                    ZStack {
                        Color("blue2").ignoresSafeArea(edges: .top)
                        Text("Board Rooms")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(height: topBarHeight)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Updating schedules...")
                        Spacer()
                    } else {

                        ScrollView {
                            VStack(spacing: 24) {

                                Image("Available today")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: bannerWidth, height: bannerHeight)
                                    .clipped()
                                    .cornerRadius(12)

                                VStack(alignment: .leading, spacing: 12) {
                                    sectionHeader(title: "My booking", actionTitle: "See All")

                                    if let lastBooking = viewModel.myBookings.last,
                                       let room = viewModel.rooms.first(where: { $0.id == lastBooking.fields.boardroomID }) {

                                        NavigationLink {
                                            RoomDetailView(
                                                roomRecord: room,
                                                existingBooking: lastBooking,
                                                roomBookings: viewModel.bookingsForRoom(room.id)
                                            )
                                        } label: {
                                            bookingCard(
                                                imageURL: room.fields.imageURL,
                                                name: room.fields.name,
                                                floor: "Floor \(room.fields.floorNo)",
                                                capacity: "\(room.fields.seatNo)",
                                                statusText: formatBookingDate(lastBooking.fields.date),
                                                statusColor: Color("blue2"),
                                                statusTextColor: .white,
                                                facilities: room.fields.facilities,
                                                imageSize: cardImageSize
                                            )
                                        }
                                        .buttonStyle(.plain).simultaneousGesture(TapGesture().onEnded {
                                            selectedRoomID = room.id
                                            applyCalendarAvailabilityForSelectedRoom()
                                        })

                                    } else {
                                        emptyStateView(message: "No active bookings found")
                                    }
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("All bookings for March")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(Color("blue2"))

                                    CalendarStripView(vm: calendarVM)

                                    ForEach(viewModel.rooms) { room in
                                        let myBooking = viewModel.myBookingForRoom(room.id)

                                        NavigationLink {
                                            RoomDetailView(
                                                roomRecord: room,
                                                existingBooking: myBooking,
                                                roomBookings: viewModel.bookingsForRoom(room.id)
                                            )
                                        } label: {
                                            bookingCard(
                                                imageURL: room.fields.imageURL,
                                                name: room.fields.name,
                                                floor: "Floor \(room.fields.floorNo)",
                                                capacity: "\(room.fields.seatNo)",
                                                statusText: myBooking == nil ? "Available" : formatBookingDate(myBooking!.fields.date),
                                                statusColor: Color("blue2"),
                                                statusTextColor: .white,
                                                facilities: room.fields.facilities,
                                                imageSize: cardImageSize
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                        }
                        .background(Color(.systemGroupedBackground))
                        .refreshable {
                            await viewModel.loadData()
                            applyGlobalCalendarAvailability()
                        }
                    }
                }
            }
        }
        .task(id: refreshToken) {
           
            await viewModel.loadData()

            applyGlobalCalendarAvailability()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func sectionHeader(title: String, actionTitle: String) -> some View {
        HStack {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundColor(Color("blue2"))
            Spacer()
            Text(actionTitle)
                .font(.subheadline)
                .foregroundColor(Color("orange2"))
        }
    }

    private func emptyStateView(message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
    }

    func formatBookingDate(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "d MMMM"
        return output.string(from: date)
    }
    private func normalizeToStartOfDay(_ ts: Int) -> Int {
        let seconds: TimeInterval = ts > 2_000_000_000_000 ? TimeInterval(ts) / 1000.0 : TimeInterval(ts)
        let d = Date(timeIntervalSince1970: seconds)
        return Int(Calendar.current.startOfDay(for: d).timeIntervalSince1970)
    }

    private func applyCalendarAvailabilityForSelectedRoom() {
        guard let roomID = selectedRoomID else {
            calendarVM.setAvailability { _ in true }
            return
        }

        // ✅ room ki booked days set
        let bookedDays = Set(
            viewModel.bookingsForRoom(roomID).map { normalizeToStartOfDay($0.fields.date) }
        )

        // ✅ calendar me jis dayTS par booking hai, wo unavailable
        calendarVM.setAvailability { date in
            let dayTS = Int(Calendar.current.startOfDay(for: date).timeIntervalSince1970)
            return !bookedDays.contains(dayTS)
        }
    }
    private func applyGlobalCalendarAvailability() {
        // ✅ jis date par koi bhi booking exist ho, wo unavailable
        let globallyBookedDays = Set(
            viewModel.bookings.map { normalizeToStartOfDay($0.fields.date) }
        )

        calendarVM.setAvailability { date in
            let dayTS = Int(Calendar.current.startOfDay(for: date).timeIntervalSince1970)
            return !globallyBookedDays.contains(dayTS)
        }
    }


    func bookingCard(
        imageURL: String,
        name: String,
        floor: String,
        capacity: String,
        statusText: String,
        statusColor: Color,
        statusTextColor: Color,
        facilities: [String],
        imageSize: CGFloat
    ) -> some View {

        HStack(spacing: 12) {

            ZStack {
                Color.gray.opacity(0.12)

                AsyncImage(url: URL(string: imageURL)) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(12)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color("blue2"))

                    Spacer()

                    Text(statusText)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .frame(height: 24)
                        .background(statusColor)
                        .foregroundColor(statusTextColor)
                        .cornerRadius(6)
                }

                Text(floor)
                    .font(.subheadline)
                    .foregroundColor(Color("dark_grey"))

                Label(capacity, systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(Color("orange2"))
                    .padding(6)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(6)

                if !facilities.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(facilities, id: \.self) { facility in
                            facilityIcon(facility)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }

    @ViewBuilder
    func facilityIcon(_ name: String) -> some View {
        switch name.lowercased() {
        case "wi-fi", "wifi":
            Image(systemName: "wifi").iconBadgeBlue()
        case "projector":
            Image(systemName: "videoprojector").iconBadgeBlue()
        case "microphone":
            Image(systemName: "mic").iconBadgeBlue()
        case "screen":
            Image(systemName: "tv").iconBadgeBlue()
        default:
            EmptyView()
        }
    }
}

extension View {
    func iconBadgeBlue() -> some View {
        self
            .font(.caption)
            .foregroundColor(Color("blue2"))
            .padding(6)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(6)
    }
}

#Preview {
    HomeView()
}
