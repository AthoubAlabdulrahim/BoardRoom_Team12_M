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
        VStack(alignment: .leading, spacing: 20) {
            Text("Welcome back! Glad to see you, Again!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 191/255, green: 93/255, blue: 49/255)) // matching orange
            
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
    }
}
#Preview {
    LoginView()
}
