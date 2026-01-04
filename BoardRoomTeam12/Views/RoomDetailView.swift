import SwiftUI

struct RoomDetailView: View {
    // 1. الخصائص التي نحتاجها من الخارج
    let roomRecord: RoomRecord
    let isExistingBooking: Bool
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RoomDetailViewModel()
    @State private var navigateToSuccess = false
    @State private var showDeleteConfirm = false
    @State private var showUpdateConfirm = false
    @State private var userSelectedDate = false

    var body: some View {
        let deviceWidth = min(UIScreen.main.bounds.width, 430)
        let horizontalPadding: CGFloat = 12 // shift content slightly left by using smaller padding
        let bannerHeight = deviceWidth * 0.72
        let gradientHeight: CGFloat = 84

        VStack(spacing: 0) {
            CustomNavBar(title: roomRecord.fields.name)
            
            GeometryReader { geo in
                let bottomInset = geo.safeAreaInsets.bottom

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // 🖼 صورة الغرفة
                        ZStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: roomRecord.fields.imageURL)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(height: bannerHeight)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal, horizontalPadding)
                        
                        // المرافق
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Facilities")
                                .font(AppFont.sectionTitle)
                                .padding(.horizontal, horizontalPadding)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(roomRecord.fields.facilities, id: \.self) { facility in
                                        FacilityChip(customIconName: getIconName(for: facility), title: facility)
                                    }
                                }
                                .padding(.horizontal, horizontalPadding)
                            }
                        }

                        // التاريخ
                        Text("Select a date")
                            .font(AppFont.sectionTitle)
                            .padding(.horizontal, horizontalPadding)

                        CalendarStripView(vm: viewModel.calendarVM)
                            .padding(.bottom, 4)

                        // الأزرار أقرب للمحتوى
                        if isExistingBooking {
                            existingBookingButtons
                        } else {
                            newBookingButton
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, max(8, bottomInset)) // safe-area aware, but minimal
                    .frame(maxWidth: .infinity, alignment: .leading) // align left
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.setup(with: roomRecord)
        }
        .onChange(of: viewModel.calendarVM.selectedDate) { _, _ in
            userSelectedDate = true
        }
    }
    
    // دالة مساعدة لاختيار الأيقونة
    func getIconName(for facility: String) -> String {
        switch facility {
        case "Wi-Fi": return "wifi"
        case "Screen": return "tv"
        case "Microphone": return "mic"
        case "Projector": return "videoprojector"
        default: return "star"
        }
    }

    // الأزرار كـ Views منفصلة لترتيب الكود
    var existingBookingButtons: some View {
        VStack(spacing: 10) {
            Button("Update") { showUpdateConfirm = true }
                .buttonStyle(PrimaryButtonStyle(isEnabled: userSelectedDate))
            
            Button("Delete booking") { showDeleteConfirm = true }
                .foregroundColor(Color("blue2"))
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding(.horizontal, 12)
        .padding(.top, 2)
        .padding(.bottom, 4)
    }

    var newBookingButton: some View {
        Button("Booking") { navigateToSuccess = true }
            .buttonStyle(PrimaryButtonStyle(isEnabled: userSelectedDate))
            .padding(.horizontal, 12)
            .padding(.top, 2)
            .padding(.bottom, 4)
            .opacity(userSelectedDate ? 1 : 0)
    }
}

// Helper لستايل الأزرار
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13) // slightly tighter to keep button nearer
            .background(Color(red: 212/255, green: 94/255, blue: 57/255))
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
