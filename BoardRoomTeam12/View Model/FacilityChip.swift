import SwiftUI

struct FacilityChip: View {

    let customIconName: String
    let title: String

    var body: some View {
        HStack(spacing: 4) {
            Image(customIconName)
                
            Text(title)
                .foregroundColor(Color(red: 35/255, green: 36/255, blue: 85/255))
        }
        .font(AppFont.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(4)
    }
}
