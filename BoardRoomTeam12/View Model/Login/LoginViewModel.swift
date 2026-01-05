import Foundation
import Combine


@MainActor
final class LoginViewModel: ObservableObject {

    // MARK: - Input
    @Published var jobNumber: String = ""
    @Published var password: String = ""

    // MARK: - UI State
    @Published var isLoading: Bool = false
    @Published var isLoggedIn: Bool = false
    @Published var loginError: String?

    private let employeeService = EmployeeService()

    // MARK: - Validation
    var canLogin: Bool {
        !jobNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !password.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Login Action
    func login() {
        loginError = nil
        isLoading = true

        Task {
            do {
                let employee = try await employeeService.login(
                    jobNumber: jobNumber,
                    password: password
                )

              
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
