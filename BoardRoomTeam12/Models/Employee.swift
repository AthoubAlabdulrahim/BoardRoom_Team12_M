import Foundation

struct EmployeesResponse: Decodable {
    let records: [Employee]
    let offset: String?
}

struct Employee: Identifiable, Decodable {
    let id: String
    let fields: EmployeeFields
    let createdTime: String?
}

struct EmployeeFields: Decodable {
    let employeeNumber: Int
    let password: String

    enum CodingKeys: String, CodingKey {
        case employeeNumber = "EmployeeNumber"
        case password = "password"
    }
}


