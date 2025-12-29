import SwiftUI

struct RoomDetailView: View {

    let roomId: String
    let isExistingBooking: Bool

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RoomDetailViewModel()
    @State private var navigateToSuccess = false
    @State private var showDeleteConfirm = false
    @State private var showUpdateConfirm = false

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
                                            withAnimation(.easeInOut) {
                                                viewModel.selectedDateID = date.id
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Hidden NavigationLink for booking flow (browse mode)
                        if !isExistingBooking {
                            NavigationLink(
                                destination: SuccessView(),
                                isActive: $navigateToSuccess
                            ) { EmptyView() }
                            .hidden()
                        }

                        // Action buttons
                        if isExistingBooking {
                            // Existing booking mode: Update + Delete
                            VStack(spacing: 12) {
                                Button {
                                    // Confirm update, then go back to HomeView
                                    showUpdateConfirm = true
                                } label: {
                                    Text("Update")
                                        .font(AppFont.button)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 212/255, green: 94/255, blue: 57/255))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .disabled(viewModel.selectedDateID == nil) // require a selected date
                                .opacity(viewModel.selectedDateID == nil ? 0.6 : 1.0)

                                Button {
                                    showDeleteConfirm = true
                                } label: {
                                    Text("Delete booking")
                                        .font(AppFont.button)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.15))
                                        .foregroundColor(Color("blue2"))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        } else {
                            // Browse mode: Booking button (only after date selection)
                            if viewModel.selectedDateID != nil {
                                Button(action: {
                                    // Perform booking, then show success
                                    navigateToSuccess = true
                                }) {
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
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            viewModel.fetchRoomDetail(roomId: roomId)
        }
        .alert("Update booking?", isPresented: $showUpdateConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Update", role: .none) {
                // Simulate saving update, then go back to Home
                dismiss()
            }
        } message: {
            Text("Change the booking to the selected date?")
        }
        .alert("Delete this booking?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                // Simulate deletion, then go back to Home
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

#Preview {
    RoomDetailView(roomId: "Ideation Room", isExistingBooking: true)
}
