import Foundation

final class EmployeeService {

    func login(jobNumber: String, password: String) async throws -> Employee {
        let response: EmployeesResponse =
            try await APIClient.shared.get(Endpoints.employees)

        guard let employee = response.records.first(where: {
            String($0.fields.employeeNumber) == jobNumber &&
            $0.fields.password == password
        }) else {
            throw NSError(domain: "Invalid credentials", code: 401)
        }


        return employee
    }
}
