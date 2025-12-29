//
//  LoginViewModel.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//
import Foundation
import Combine

class LoginViewModel: ObservableObject {
    // Input fields bound to the UI
    @Published var jobNumber: String = ""
    @Published var password: String = ""
    
    // Output for UI feedback (optional)
    @Published var loginError: String?
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    
    // Simple validation example
    var canLogin: Bool {
        !jobNumber.isEmpty && !password.isEmpty
    }
    
    func login() {
        // Clear previous error
        loginError = nil
        
        // Example validation
        guard canLogin else {
            loginError = "Please fill in both fields."
            return
        }
        
        isLoading = true
        
        // Here you will add your networking call to login API.
        // For now, let's simulate success with a delay:
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            
            // For demo: check dummy jobNumber and password
            if self.jobNumber == "12345" && self.password == "password" {
                self.isLoggedIn = true
            } else {
                self.loginError = "Invalid job number or password."
            }
        }
    }
}

