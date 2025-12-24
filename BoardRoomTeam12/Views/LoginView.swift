//
//  LoginView.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isPasswordVisible = false
    
    private let fieldWidth: CGFloat = 340
    private let fieldHeight: CGFloat = 58
    private let buttonHeight: CGFloat = 58
    private let topImageHeight: CGFloat = 400
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Image("backgroundLines")
                .resizable()
                .scaledToFill()
                .frame(height: topImageHeight)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea(edges: .top)
            
            VStack(alignment: .leading, spacing: 5) {
                
                Spacer()
                    .frame(height: 150)
                
                Text("Welcome back! Glad to see you, Again!")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color(red: 191/255, green: 93/255, blue: 49/255))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .minimumScaleFactor(0.85)     // Prevents overflow
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                VStack(spacing: 20) {
                    
                    TextField("Enter your job number", text: $viewModel.jobNumber)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(width: fieldWidth, height: fieldHeight)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        )
                        .cornerRadius(12)
                    
                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $viewModel.password)
                            } else {
                                SecureField("Enter your password", text: $viewModel.password)
                            }
                        }
                        .autocapitalization(.none)
                        .frame(width: fieldWidth, height: fieldHeight)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        
                        Button {
                            isPasswordVisible.toggle()
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(.trailing, 16)
                        }
                    }
                    
                    if let error = viewModel.loginError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(width: fieldWidth, alignment: .leading)
                    }
                    
                    Button {
                        viewModel.login()
                    } label: {
                        Text(viewModel.isLoading ? "Logging in..." : "Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 370, height: buttonHeight)
                            .background(Color(red: 33/255, green: 38/255, blue: 82/255))
                            .cornerRadius(12)
                    }
                    .disabled(!viewModel.canLogin || viewModel.isLoading)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .background(Color(red: 0.953, green: 0.953, blue: 0.953))
                .ignoresSafeArea()
      //  .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    LoginView()
}
