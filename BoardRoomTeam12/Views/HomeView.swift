//
//  HomeView.swift
//  BoardRoomTeam12
//
//  Created by Jamilah Jaber Hazazi on 03/07/1447 AH.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = BookingViewModel()
    @StateObject private var calendarVM = CalendarStripViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = min(geo.size.width, 430) // tune for iPhone 17 Pro
                let topBarHeight: CGFloat = 52
                let bannerWidth = width - 2 * 16
                let bannerHeight = bannerWidth * 0.385 // ~138 when width ~358
                let cardImageSize: CGFloat = 80

                VStack(spacing: 0) {
                    // 🔵 الشريط العلوي
                    ZStack {
                        Color("blue2").ignoresSafeArea(edges: .top)
                        Text("Board Rooms").font(.headline).foregroundColor(.white)
                    }
                    .frame(height: topBarHeight)
                    
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("Updating schedules...")
                        Spacer()
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                // 🔶 البانر الإعلاني
                                Image("Available today")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: bannerWidth, height: bannerHeight)
                                    .clipped()
                                    .cornerRadius(12)
                                
                                // 📌 قسم "My booking" (ديناميكي وخاص بالمستخدم)
                                VStack(alignment: .leading, spacing: 12) {
                                    sectionHeader(title: "My booking", actionTitle: "See All")
                                    
                                    if let lastBooking = viewModel.myBookings.last,
                                       let room = viewModel.rooms.first(where: { $0.id == lastBooking.fields.boardroomID }) {
                                        
                                        NavigationLink {
                                            RoomDetailView(roomRecord: room, isExistingBooking: true)
                                        } label: {
                                            bookingCard(
                                                imageURL: room.fields.imageURL,
                                                name: room.fields.name,
                                                floor: "Floor \(room.fields.floorNo)",
                                                capacity: "\(room.fields.seatNo)",
                                                statusText: formatDate(lastBooking.fields.formattedDate),
                                                statusColor: Color("blue2"),
                                                statusTextColor: .white,
                                                facilities: room.fields.facilities,
                                                imageSize: cardImageSize
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        emptyStateView(message: "No active bookings found")
                                    }
                                }
                                
                                // 📌 قسم "All bookings for March"
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("All bookings for March")
                                        .font(.title3).bold().foregroundColor(Color("blue2"))
                                    
                                    CalendarStripView(vm: calendarVM)
                                    
                                    ForEach(viewModel.rooms) { room in
                                        NavigationLink {
                                            RoomDetailView(roomRecord: room, isExistingBooking: false)
                                        } label: {
                                            bookingCard(
                                                imageURL: room.fields.imageURL,
                                                name: room.fields.name,
                                                floor: "Floor \(room.fields.floorNo)",
                                                capacity: "\(room.fields.seatNo)",
                                                statusText: "Available",
                                                statusColor: Color("AvailableColor"),
                                                statusTextColor: Color("light_green"),
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
                            .frame(maxWidth: 600) // readable width
                            .frame(maxWidth: .infinity)
                        }
                        .background(Color(.systemGroupedBackground))
                        .refreshable { await viewModel.loadData() }
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    // MARK: - مكونات إضافية لتنظيف الكود
    
    private func sectionHeader(title: String, actionTitle: String) -> some View {
        HStack {
            Text(title).font(.title3).bold().foregroundColor(Color("blue2"))
            Spacer()
            Text(actionTitle).font(.subheadline).foregroundColor(Color("orange2"))
        }
    }
    
    private func emptyStateView(message: String) -> some View {
        Text(message)
            .font(.caption).foregroundColor(.gray)
            .frame(maxWidth: .infinity).padding().background(Color.white.opacity(0.5)).cornerRadius(12)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
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
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: URL(string: imageURL)) { img in
                img.resizable().scaledToFill()
            } placeholder: { Color.gray.opacity(0.1) }
            .frame(width: imageSize, height: imageSize)
            .cornerRadius(12)
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(name).font(.headline).foregroundColor(Color("blue2"))
                    Spacer()
                    Text(statusText)
                        .font(.system(size: 12, weight: .regular))
                        .padding(.horizontal, 8)
                        .frame(height: 26)
                        .background(statusText == "Available" ? Color("dark_green").opacity(0.1) : statusColor)
                        .foregroundColor(statusText == "Available" ? Color("dark_green") : statusTextColor)
                        .cornerRadius(6)
                }
                
                Text(floor).font(.subheadline).foregroundColor(Color("dark_grey"))
                
                HStack(spacing: 8) {
                    Label(capacity, systemImage: "person.2")
                        .font(.caption).foregroundColor(Color("orange2"))
                        .padding(6).background(Color.gray.opacity(0.12)).cornerRadius(6)
                    
                    HStack(spacing: 4) {
                        if facilities.contains("Wi-Fi") { Image(systemName: "wifi").iconBadgeBlue() }
                        if facilities.contains("Screen") || facilities.contains("Projector") { Image(systemName: "tv").iconBadgeBlue() }
                        if facilities.contains("Microphone") { Image(systemName: "mic").iconBadgeBlue() }
                    }
                }
            }
        }
        .padding()
        .background(Color.white).cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}
extension View {
    func iconBadgeBlue() -> some View {
        self
            .font(.caption)
            .foregroundColor(Color("blue2")) // تأكد أن هذا اللون معرف في Assets
            .padding(6)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(6)
    }
}
