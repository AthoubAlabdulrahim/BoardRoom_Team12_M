//
//  LoginView.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Image
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300) // Adjust height as needed
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea(edges: .top)
            
            // Main content
            ScrollView {
                VStack(spacing: 0) {
                    // Spacer to push content below the image
                    Color.clear
                        .frame(height: 200) // Should be slightly less than image height
                    
                    // Login form
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Welcome back! Glad to see you, Again!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 191/255, green: 93/255, blue: 49/255))
                            .padding(.top, 20)
                        
                        TextField("Enter your job number", text: $viewModel.jobNumber)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Enter your password", text: $viewModel.password)
                            .textFieldStyle(.roundedBorder)
                        
                        if let error = viewModel.loginError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                        
                        Button(action: {
                            viewModel.login()
                        }) {
                            Text(viewModel.isLoading ? "Logging in..." : "Login")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.canLogin ? Color(red: 30/255, green: 30/255, blue: 67/255) : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(!viewModel.canLogin || viewModel.isLoading)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white) // White background for the form
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(radius: 5)
                }
            }
            .ignoresSafeArea()
        }
        .background(Color.white.ignoresSafeArea()) // Ensure white background behind everything
    }
}

// Extension for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    LoginView()
}
