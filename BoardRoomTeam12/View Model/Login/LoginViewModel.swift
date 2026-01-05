import Foundation
import Combine


@MainActor
final class LoginViewModel: ObservableObject {

   
    @Published var jobNumber: String = ""
    @Published var password: String = ""

    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var loginError: String?

    // here we have created the instance of employees service to use it
    private let employeeService = EmployeeService()

    
    var canLogin: Bool {
        !jobNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty
    }

    
    func login() {
        loginError = nil
        isLoading = true

        Task {
            do {
                // here we call login service defined in employees service and send the request
                let employee = try await employeeService.login(
                    jobNumber: jobNumber,
                    password: password
                )
                //here we have stored the session in the local storage of the phone
                //so it will stays logged in as defined in userSession file in core
                UserSession.shared.employeeID = employee.id
                isLoggedIn = true

            } catch let error as APIError {
                loginError = error.localizedDescription
            } catch {
                loginError = "Invalid job number or password"
            }
            isLoading = false
        }
    }
}
