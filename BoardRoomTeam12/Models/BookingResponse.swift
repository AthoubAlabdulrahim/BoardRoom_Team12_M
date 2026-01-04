//
//  BookingResponse.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 15/07/1447 AH.
//
import Foundation

struct BookingResponse: Codable {
    let records: [BookingRecord]
}

struct BookingRecord: Identifiable, Codable {
    let id: String
    let fields: BookingFields
}

struct BookingFields: Codable {
    let employeeID: String
    let boardroomID: String
    let date: Int // هذا Unix Timestamp

    enum CodingKeys: String, CodingKey {
        case employeeID = "employee_id"
        case boardroomID = "boardroom_id"
        case date
    }
    
    // دالة مساعدة لتحويل الرقم إلى تاريخ حقيقي (Date)
    var formattedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(date))
    }
}
