import Foundation

// Root response
struct RecordsResponse: Codable {
    let records: [EmployeeRecord]
}

// A single record
struct EmployeeRecord: Codable {
    let id: String
    let createdTime: Date
    let fields: EmployeeFields
}

// The "fields" object
struct EmployeeFields: Codable {
    let EmployeeNumber: Int
    let name: String
    let job_title: String
    let password: String
    let email: String
}

