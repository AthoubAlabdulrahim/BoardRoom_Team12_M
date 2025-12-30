import SwiftUI

struct RoomDetailView: View {

    let roomId: String
    let isExistingBooking: Bool

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RoomDetailViewModel()
    @State private var navigateToSuccess = false
    @State private var showDeleteConfirm = false
    @State private var showUpdateConfirm = false

    // Track whether the user explicitly picked a date (to mimic previous enabling behavior)
    @State private var userSelectedDate = false

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

                        Text("Select a date")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal)

                        // Reusable calendar strip
                        CalendarStripView(vm: viewModel.calendarVM)
                            .padding(.horizontal, 0)

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
                                .disabled(!userSelectedDate)
                                .opacity(!userSelectedDate ? 0.6 : 1.0)

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
                            // Browse mode: Booking button (enabled after user picked a date)
                            if userSelectedDate {
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
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .onAppear {
            viewModel.fetchRoomDetail(roomId: roomId)
        }
        // Flip the flag when the user changes the selection in the calendar strip
        .onChange(of: viewModel.calendarVM.selectedDate) { _ in
            userSelectedDate = true
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
