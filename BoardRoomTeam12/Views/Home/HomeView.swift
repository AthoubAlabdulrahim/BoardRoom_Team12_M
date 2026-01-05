import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = BookingViewModel()
    @StateObject private var calendarVM = CalendarStripViewModel()

    @State private var refreshToken = UUID()
    @State private var selectedRoomID: String? = nil

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let layout = Layout(width: geo.size.width)

                VStack(spacing: 0) {

                    // Top Bar (dark + light friendly)
                    ZStack {
                        Color("blue2").ignoresSafeArea(edges: .top)

                        Text("Board Rooms")
                            .font(.headline)
                            .foregroundColor(Color("blue"))
                            .accessibilityAddTraits(.isHeader)
                    }
                    .frame(height: layout.topBarHeight)

                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Updating schedules...")
                        Spacer()
                    } else {

                        ScrollView {
                            VStack(spacing: layout.sectionSpacing) {

                                // Banner
                                Image("Available today")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: layout.bannerHeight)
                                    .clipped()
                                    .cornerRadius(layout.bannerCornerRadius)

                                // My booking
                                VStack(alignment: .leading, spacing: layout.blockSpacing) {
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
                                                statusTextColor: Color.appOnBlue,
                                                facilities: room.fields.facilities,
                                                imageSize: layout.cardImageSize
                                                    
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .simultaneousGesture(TapGesture().onEnded {
                                            selectedRoomID = room.id
                                            applyCalendarAvailabilityForSelectedRoom()
                                        })

                                    } else {
                                        emptyStateView(message: "No active bookings found", layout: layout)
                                    }
                                }

                               
                                VStack(alignment: .leading, spacing: layout.blockSpacing) {
                                    Text("All bookings for March")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(Color("blue2"))

                                    CalendarStripView(vm: calendarVM)

                                    LazyVStack(spacing: layout.cardSpacing) {
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
                                                    statusColor: Color("blue"),
                                                    statusTextColor: Color.appOnBlue,
                                                    facilities: room.fields.facilities,
                                                    imageSize: layout.cardImageSize
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, layout.sidePadding)
                            .padding(.vertical, layout.verticalPadding)
                        }
                        .background(Color.appGroupedBackground)
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

    // MARK: UI Parts

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

    private func emptyStateView(message: String, layout: Layout) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(Color.appSecondaryText)
            .frame(maxWidth: .infinity)
            .padding(layout.emptyStatePadding)
            .background(Color.appCardBackground)
            .cornerRadius(layout.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: layout.cardCornerRadius)
                    .stroke(Color.appBorder, lineWidth: 1)
            )
    }

    // MARK: Date helpers

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

    // MARK: Calendar availability

    private func applyCalendarAvailabilityForSelectedRoom() {
        guard let roomID = selectedRoomID else {
            calendarVM.setAvailability { _ in true }
            return
        }

        let bookedDays = Set(
            viewModel.bookingsForRoom(roomID).map { normalizeToStartOfDay($0.fields.date) }
        )

        calendarVM.setAvailability { date in
            let dayTS = Int(Calendar.current.startOfDay(for: date).timeIntervalSince1970)
            return !bookedDays.contains(dayTS)
        }
    }

    private func applyGlobalCalendarAvailability() {
        let globallyBookedDays = Set(
            viewModel.bookings.map { normalizeToStartOfDay($0.fields.date) }
        )

        calendarVM.setAvailability { date in
            let dayTS = Int(Calendar.current.startOfDay(for: date).timeIntervalSince1970)
            return !globallyBookedDays.contains(dayTS)
        }
    }

    // MARK: Card

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

        HStack(alignment: .top, spacing: 12) {

            ZStack {
                Color.appImagePlaceholder

                AsyncImage(url: URL(string: imageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(Color.appSecondaryText)
                    }
                }
            }
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(12)
            .clipped()

            VStack(alignment: .leading, spacing: 8) {

                HStack(alignment: .top) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color.appText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)

                    Spacer(minLength: 8)

                    Text(statusText)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .background(statusColor)
                        .foregroundColor(statusTextColor)
                        .cornerRadius(6)
                        .lineLimit(1)
                }

                Text(floor)
                    .font(.subheadline)
                    .foregroundColor(Color.appSecondaryText)

                Label(capacity, systemImage: "person.2")
                    .font(.caption)
                    .foregroundColor(Color.appOrange)
                    .padding(6)
                    .background(Color.appTagBackground)
                    .cornerRadius(6)

                if !facilities.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(facilities, id: \.self) { facility in
                            facilityIcon(facility)
                        }
                    }
                    .padding(.top, 2)
                    
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.appCardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appBorder, lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.12 : 0.06),
            radius: 5,
            x: 0,
            y: 2
        )
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



private struct Layout {
    let width: CGFloat

    var topBarHeight: CGFloat { 52 }

    var sidePadding: CGFloat {
        width < 360 ? 12 : 16
    }

    var verticalPadding: CGFloat {
        width < 360 ? 12 : 16
    }

    var sectionSpacing: CGFloat {
        width < 360 ? 16 : 24
    }

    var blockSpacing: CGFloat {
        width < 360 ? 10 : 12
    }

    var cardSpacing: CGFloat {
        width < 360 ? 10 : 12
    }

    var bannerHeight: CGFloat {
        let w = max(width - (sidePadding * 2), 1)
        let h = w * 0.385
        return min(max(h, 130), 220)
    }

    var bannerCornerRadius: CGFloat { 12 }

    var cardImageSize: CGFloat {
        width < 360 ? 68 : 80
    }

    var cardCornerRadius: CGFloat { 12 }

    var emptyStatePadding: CGFloat {
        width < 360 ? 12 : 14
    }
}

// MARK: Theme colors (dark + light)

extension Color {
    static let appBlue = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(red: 0.32, green: 0.56, blue: 0.98, alpha: 1.0)
        : UIColor(red: 0.10, green: 0.33, blue: 0.93, alpha: 1.0)
    })

    static let appOnBlue = Color.white

    static let appOrange = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(red: 1.00, green: 0.70, blue: 0.35, alpha: 1.0)
        : UIColor(red: 0.98, green: 0.45, blue: 0.10, alpha: 1.0)
    })

    static let appText = Color(uiColor: .label)
    static let appSecondaryText = Color(uiColor: .secondaryLabel)

    static let appGroupedBackground = Color(uiColor: .systemGroupedBackground)
    static let appCardBackground = Color(uiColor: .secondarySystemBackground)

    static let appBorder = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.10)
        : UIColor.black.withAlphaComponent(0.08)
    })

    static let appTagBackground = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.07)
        : UIColor.black.withAlphaComponent(0.06)
    })

    static let appImagePlaceholder = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.06)
        : UIColor.black.withAlphaComponent(0.05)
    })
}

extension View {
    func iconBadgeBlue() -> some View {
        self
            .font(.caption)
            .padding(6)
            .foregroundColor(Color("blue2"))
            .background(Color.appTagBackground)
            .cornerRadius(6)
    }
}

#Preview {
    HomeView()
}
