import SwiftUI

struct CustomNavBar: View {
    let title: String
    var body: some View {
        ZStack {
            Color(red: 35/255, green: 36/255, blue: 85/255)
                .ignoresSafeArea(edges: .top)

            HStack {
                Image("Icon")
                    .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 28)
                        .foregroundColor(.white)
                    Spacer()
                    .frame(width: 116)
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                            }
            .padding(.horizontal)
            .padding(.top, 11)
            .padding(.bottom, 11)
        }
        .frame(height: 44)
    }
}

