import SwiftUI

struct RoomDetailView: View {

    @StateObject private var viewModel = RoomDetailViewModel()

    var body: some View {
        VStack(spacing: 0) {

            CustomNavBar(title: viewModel.room?.name ?? "Room")

            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }

            ScrollView {
                if let room = viewModel.room {

                    VStack(alignment: .leading, spacing: 16) {
                        
                        ZStack(alignment: .bottom) {
                            Image(room.imageUrl)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 323)
                                .clipped()

                            LinearGradient(
                                colors: [.clear, .white],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 80)

                            HStack {
                                Label("Floor \(room.floor)", systemImage: "paperplane")
                                    .font(AppFont.caption)
                                    .foregroundColor(Color(red: 35/255, green: 36/255, blue: 85/255))

                                Spacer()

                                Label {
                                    Text("\(room.capacity)")
                                        .font(AppFont.caption)
                                } icon: {
                                    Image("person")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                .foregroundColor(.orange)
                                .padding(6)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            .padding()
                        }

                        
                        Text("Description")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal)

                        Text(room.description)
                            .font(AppFont.body)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(6)
                            .padding(.horizontal)

                        
                        Text("Facilities")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(room.facilities) { facility in
                                    FacilityChip(
                                        customIconName: facility.icon,
                                        title: facility.title
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }

                        
                        Text("All bookings for March")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 18) {
                                ForEach(room.availableDates) { date in
                                    CalendarCircleView(
                                        model: date,
                                        isSelected: viewModel.selectedDateID == date.id
                                    )
                                    .onTapGesture {
                                        if date.isAvailable {
                                            viewModel.selectedDateID = date.id
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        
                        Button(action: {}) {
                            Text("Booking")
                                .font(AppFont.button)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 212/255, green: 94/255, blue: 57/255))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.fetchRoomDetail(roomId: "room_123")
        }
    }
}

#Preview {
    RoomDetailView()
}
