//
//  LoginViewModel.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//
import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    // Dependencies
    private let api: EmployeeService

    // Input fields bound to the UI
    @Published var jobNumber: String = ""
    @Published var password: String = ""
    
    // Output for UI feedback (optional)
    @Published var loginError: String?
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    
    // Init with dependency injection (default to the real API)
    init(api: EmployeeService = DefaultEmployeeService()) {
        self.api = api
    }
    
    // Simple validation example
    var canLogin: Bool {
        !jobNumber.isEmpty && !password.isEmpty
    }
    
    func login() {
        loginError = nil
        
        guard canLogin else {
            loginError = "Please fill in both fields."
            return
        }

        guard let jobNumberInt = Int(jobNumber) else {
            loginError = "Job number must be digits only."
            return
        }
        
        isLoading = true

        Task {
            defer { isLoading = false }

            do {
                let response = try await api.fetchEmployee(jobNumber: jobNumberInt)
                guard let record = response.records.first else {
                    loginError = "Invalid job number or password."
                    return
                }

                // Compare password locally
                if record.fields.password == password {
                    // Optionally store user info (record.id, name, email) for later use
                    print("Logged in as: \(record.fields.name) (\(record.fields.email))")
                    isLoggedIn = true
                } else {
                    loginError = "Invalid job number or password."
                }
            } catch {
                if let apiError = error as? APIError {
                    loginError = apiError.localizedDescription
                } else {
                    loginError = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
}
