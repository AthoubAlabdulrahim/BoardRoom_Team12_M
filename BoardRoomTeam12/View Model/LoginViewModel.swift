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
    private let api: EmployeeService
    
    @Published var jobNumber: String = ""
    @Published var password: String = ""
    @Published var loginError: String?
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    
    init(api: EmployeeService? = nil) {
        self.api = api ?? DefaultEmployeeService()
    }
    
    var canLogin: Bool { !jobNumber.isEmpty && !password.isEmpty }
    
    func login() {
        loginError = nil
        guard canLogin else { return }
        
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
                
                // التحقق من كلمة المرور
                if record.fields.password == password {
                    // 🔥 السطر السحري: حفظ معرف الموظف (Record ID)
                    UserDefaults.standard.set(record.id, forKey: "current_employee_id")
                    
                    print("Logged in successfully as: \(record.fields.name)")
                    isLoggedIn = true
                } else {
                    loginError = "Invalid job number or password."
                }
            } catch {
                loginError = error.localizedDescription
            }
        }
    }
}
