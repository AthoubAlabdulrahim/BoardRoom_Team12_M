//
//  SuccessView.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 04/07/1447 AH.
//
import SwiftUI

struct SuccessView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {

            ZStack {
                Image("backgroundLines")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()

                Image("CircleIcon")
                    .resizable()
                    .frame(width: 253, height: 253)
                    .offset(y: 60)
            }
            .padding(.bottom, 20)

            Text("Booking Success!")
                .font(.largeTitle.bold())
                .foregroundColor(Color(red: 33/255, green: 38/255, blue: 82/255))
                .padding(.bottom, 15)

            Text("Your booking for Ideation Room on Sunday, March 19, 2023 is confirmed.")
                .font(.footnote.bold())
                .foregroundColor(Color("blue2"))
                .multilineTextAlignment(.center)
                .frame(width: 358, height: 69)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.1), radius: 6)
                .padding(.bottom, 40)

            Spacer()

            Button(action: {
                // Pop SuccessView
                dismiss()
                // Then pop RoomDetailView back to HomeView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    dismiss()
                }
            }) {
                Text("Done")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 191/255, green: 93/255, blue: 49/255))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(edges: .top)
        .background(Color(red: 0.953, green: 0.953, blue: 0.953))
        .ignoresSafeArea()
      //  .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    SuccessView()
}
