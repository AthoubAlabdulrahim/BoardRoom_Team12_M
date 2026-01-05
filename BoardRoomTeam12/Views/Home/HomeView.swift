import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = BookingViewModel()
    @StateObject private var calendarVM = CalendarStripViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let layout = Layout(width: geo.size.width)

                VStack(spacing: 0) {
                    // Top Bar
                    ZStack {
                        Color("blue2").ignoresSafeArea(edges: .top)
                        Text("Board Rooms")
                            .font(.headline)
                            .foregroundColor(.white)
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

                                // 1. My booking section
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
                                                facilities: room.fields.facilities,
                                                imageSize: layout.cardImageSize,
                                                isMyBooking: true
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        emptyStateView(message: "No active bookings found", layout: layout)
                                    }
                                }

                                // 2. All bookings section
                                VStack(alignment: .leading, spacing: layout.blockSpacing) {
                                    Text("All bookings for January")
                                        .font(.title3)
                                        .bold()
                                        .foregroundColor(Color("blue2"))

                                    CalendarStripView(vm: calendarVM)

                                    LazyVStack(spacing: layout.cardSpacing) {
                                        // ترتيب الغرف أبجدياً
                                        ForEach(viewModel.rooms.sorted(by: { $0.fields.name < $1.fields.name })) { room in
                                            
                                            // التحقق الدقيق من حالة الغرفة بناءً على اليوم المختار في التقويم
                                            let isOccupied = viewModel.bookings.contains { booking in
                                                let isSameRoom = booking.fields.boardroomID == room.id
                                                // استخدام نفس منطق التحويل الموجود في الـ ViewModel الخاص بك
                                                let bookingDay = normalizeToStartOfDay(booking.fields.date)
                                                let selectedDay = normalizeToStartOfDay(Int(calendarVM.selectedDate.timeIntervalSince1970))
                                                return isSameRoom && bookingDay == selectedDay
                                            }

                                            NavigationLink {
                                                RoomDetailView(
                                                    roomRecord: room,
                                                    existingBooking: viewModel.myBookingForRoom(room.id),
                                                    roomBookings: viewModel.bookingsForRoom(room.id)
                                                )
                                            } label: {
                                                bookingCard(
                                                    imageURL: room.fields.imageURL,
                                                    name: room.fields.name,
                                                    floor: "Floor \(room.fields.floorNo)",
                                                    capacity: "\(room.fields.seatNo)",
                                                    statusText: isOccupied ? "Unavailable" : "Available",
                                                    facilities: room.fields.facilities,
                                                    imageSize: layout.cardImageSize,
                                                    isMyBooking: false
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
                        .background(Color(.systemGroupedBackground))
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Logic Helpers (مطابقة تماماً للـ ViewModel الخاص بك)
    private func normalizeToStartOfDay(_ ts: Int) -> Int {
        let seconds: TimeInterval = ts > 2_000_000_000_000 ? TimeInterval(ts) / 1000.0 : TimeInterval(ts)
        let d = Date(timeIntervalSince1970: seconds)
        return Int(Calendar.current.startOfDay(for: d).timeIntervalSince1970)
    }

    private func formatBookingDate(_ timestamp: Int) -> String {
        let seconds: TimeInterval = timestamp > 2_000_000_000_000 ? TimeInterval(timestamp) / 1000.0 : TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: seconds)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }

    // MARK: - UI Components
    private func sectionHeader(title: String, actionTitle: String) -> some View {
        HStack {
            Text(title).font(.title3).bold().foregroundColor(Color("blue2"))
            Spacer()
            Text(actionTitle).font(.subheadline).foregroundColor(Color("orange2"))
        }
    }

    func bookingCard(imageURL: String, name: String, floor: String, capacity: String, statusText: String, facilities: [String], imageSize: CGFloat, isMyBooking: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(12)
            .clipped()

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(name).font(.headline).foregroundColor(Color("blue2"))
                    Spacer()
                    
                    Text(statusText)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .frame(height: 24)
                        .background(
                            isMyBooking ? Color("blue2") :
                            (statusText == "Available" ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                        )
                        .foregroundColor(
                            isMyBooking ? .white :
                            (statusText == "Available" ? .green : .red)
                        )
                        .cornerRadius(6)
                }

                Text(floor).font(.subheadline).foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Label(capacity, systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(Color("orange2"))
                        .padding(6)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(6)

                    HStack(spacing: 6) {
                        ForEach(facilities, id: \.self) { facility in
                            facilityIcon(facility)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }

    @ViewBuilder
    func facilityIcon(_ name: String) -> some View {
        let icon: String = {
            switch name.lowercased() {
            case "wi-fi", "wifi": return "wifi"
            case "projector": return "videoprojector"
            case "microphone": return "mic"
            case "screen": return "tv"
            default: return "star"
            }
        }()
        
        Image(systemName: icon)
            .font(.system(size: 10))
            .padding(6)
            .foregroundColor(Color("blue2"))
            .background(Color(UIColor.systemGray6))
            .cornerRadius(6)
    }

    private func emptyStateView(message: String, layout: Layout) -> some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
    }
}

private struct Layout {
    let width: CGFloat
    var topBarHeight: CGFloat { 52 }
    var sidePadding: CGFloat { 16 }
    var verticalPadding: CGFloat { 16 }
    var sectionSpacing: CGFloat { 24 }
    var blockSpacing: CGFloat { 12 }
    var cardSpacing: CGFloat { 12 }
    var bannerHeight: CGFloat { 140 }
    var bannerCornerRadius: CGFloat { 12 }
    var cardImageSize: CGFloat { 85 }
}

#Preview {
    HomeView()
}
