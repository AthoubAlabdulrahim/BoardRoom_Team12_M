import Foundation

final class UserSession {

    static let shared = UserSession()
    private init() {}

    private let employeeKey = "logged_in_employee_id"

    var employeeID: String? {
        get { UserDefaults.standard.string(forKey: employeeKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: employeeKey) }
    }

    var isLoggedIn: Bool {
        employeeID != nil
    }

    func logout() {
        employeeID = nil
    }
}
