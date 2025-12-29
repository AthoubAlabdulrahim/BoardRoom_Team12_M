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
            VStack(spacing: 0) {

                // 🔵 Top Bar
                ZStack {
                    Color("blue2")
                        .ignoresSafeArea(edges: .top)

                    Text("Board Rooms")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(height: 44)

                // 📜 Content
                ScrollView {
                    VStack(spacing: 24) {

                        // 🔶 Banner
                        Image("Available today")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 358 , height: 138)
                            .cornerRadius(10)

                        // 📌 My booking
                        VStack(alignment: .leading, spacing: 12) {

                            HStack {
                                Text("My booking")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(Color("blue2"))

                                Spacer()

                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(Color("orange2"))
                            }

                            NavigationLink {
                                // Navigate in existing-booking mode
                                RoomDetailView(roomId: "Creative Space", isExistingBooking: true)
                            } label: {
                                bookingCard(
                                    imageName: "room1",
                                    name: "Creative Space",
                                    floor: "Floor 5",
                                    capacity: "1",
                                    statusText: "28 March",
                                    statusColor: Color("blue2"),
                                    statusTextColor: .white
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // 📌 All bookings
                        VStack(alignment: .leading, spacing: 12) {

                            Text("All bookings for March")
                                .font(.title3)
                                .bold()
                                .foregroundColor(Color("blue2"))

                            // 📅 Days
                            CalendarStripView(vm: calendarVM)

                            // 🪑 Rooms
                            ForEach(viewModel.rooms) { room in
                                NavigationLink {
                                    // Navigate in browse mode (new booking)
                                    RoomDetailView(roomId: room.name, isExistingBooking: false)
                                } label: {
                                    bookingCard(
                                        imageName: room.imageName,
                                        name: room.name,
                                        floor: room.floor,
                                        capacity: "\(room.capacity)",
                                        statusText: room.isAvailable ? "Available" : "Unavailable",
                                        statusColor: room.isAvailable
                                            ? Color("AvailableColor")
                                            : Color("UnavailableColor"),
                                        statusTextColor: room.isAvailable
                                            ? Color("light_green")
                                            : Color("light_pink")
                                    )
                                }
                                .buttonStyle(.plain) // keep the card styling unchanged
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }

    // 🔁 Room Card
    func bookingCard(
        imageName: String,
        name: String,
        floor: String,
        capacity: String,
        statusText: String,
        statusColor: Color,
        statusTextColor: Color
    ) -> some View {

        HStack(alignment: .center, spacing: 12) {

            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()

            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color("blue2"))

                    Spacer()

                    Text(statusText)
                        .font(.system(size: 12, weight: .regular))
                        .frame(width: 80, height: 26)
                        .padding(.vertical, 4)
                        .background(
                            statusText == "Available" ? Color("dark_green").opacity(0.1) :
                            statusText == "Unavailable" ? Color("dark_red").opacity(0.1) :
                            statusColor
                        )

                        .foregroundColor(
                            statusText == "Available" ? Color("dark_green") :
                            statusText == "Unavailable" ? Color("dark_red") :
                            statusTextColor
                        )
                        .cornerRadius(6)

                }

                Text(floor)
                    .font(.subheadline)
                    .foregroundColor(Color("dark_grey"))

                HStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .foregroundColor(Color("orange2"))
                        Text(capacity)
                            .font(.caption)
                            .foregroundColor(Color("orange2"))
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.12))
                    .cornerRadius(6)
                }

                HStack(spacing: 8) {
                    Image(systemName: "wifi")
                        .iconBadgeBlue()

                    if name == "Ideation Room" || name == "Inspiration Room" {
                        if name == "Ideation Room" {
                            Image(systemName: "tv")
                                .iconBadgeBlue()
                        }

                        if name == "Inspiration Room" {
                            Image(systemName: "microphone")
                                .iconBadgeBlue()

                            Image(systemName: "videoprojector")
                                .iconBadgeBlue()
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
}

#Preview {
    HomeView()
}

extension View {
    func iconBadge() -> some View {
        self
            .font(.caption)
            .foregroundColor(Color("dark_grey"))
            .padding(6)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(6)
    }
    
    func iconBadgeBlue() -> some View {
        self
            .font(.caption)
            .foregroundColor(Color("blue2"))
            .padding(6)
            .background(Color.gray.opacity(0.12))
            .cornerRadius(6)
    }
}
