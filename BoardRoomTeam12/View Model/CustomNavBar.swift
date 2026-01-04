//View Model/CustomNavBar

import SwiftUI

struct CustomNavBar: View {
    let title: String
    var onBack: (() -> Void)? = nil

    var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width, 430)
            let barHeight: CGFloat = 52

            ZStack {
                Color(red: 35/255, green: 36/255, blue: 85/255)
                    .ignoresSafeArea(edges: .top)

                HStack(spacing: 12) {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                    } else {
                        // Keep space so title remains centered if no back button
                        Color.clear.frame(width: 28, height: 28)
                    }

                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))

                    Spacer()

                    // Right side placeholder for symmetry if needed
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal)
            }
            .frame(height: barHeight)
        }
        .frame(height: 52)
    }
}
