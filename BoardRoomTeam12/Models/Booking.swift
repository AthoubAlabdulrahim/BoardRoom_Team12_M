//
//  Booking.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 13/07/1447 AH.
//
// Models/Booking.swift
import Foundation

// MARK: - Root response (Matches exactly your JSON)
struct BookingsResponse: Codable {
    let records: [BookingRecord]
}

// MARK: - Single record (Matches exactly your JSON)
struct BookingRecord: Codable, Identifiable {
    let id: String
    let createdTime: Date
    let fields: BookingFields
}

// MARK: - Fields object (Matches exactly your JSON fields)
struct BookingFields: Codable {
    // These MUST match your Airtable column names exactly!
    let employee_id: String  // This is a single string, not an array
    let boardroom_id: String // This is a single string, not an array
    let date: Double  // This is a Unix timestamp (seconds since 1970)
    
    // Computed property to convert Unix timestamp to Date
    var dateObject: Date {
        return Date(timeIntervalSince1970: date)
    }
    
    // Computed property to format date as string
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dateObject)
    }
    
    // Computed property to format time
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: dateObject)
    }
    
    // Add this if you need date in yyyy-MM-dd format
    var yyyyMMdd: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dateObject)
    }
}

// MARK: - For creating new bookings (Adjust based on your needs)
struct CreateBookingFields: Codable {
    // Use the exact field names from your Airtable
    let employee_id: String
    let boardroom_id: String
    let date: Double  // Unix timestamp
    
    init(employeeId: String, boardroomId: String, date: Date) {
        self.employee_id = employeeId
        self.boardroom_id = boardroomId
        self.date = date.timeIntervalSince1970
    }
    
    // Alternative init with date string
    init(employeeId: String, boardroomId: String, dateString: String, timeString: String) {
        self.employee_id = employeeId
        self.boardroom_id = boardroomId
        
        // Combine date and time, then convert to Unix timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let combinedDateTime = "\(dateString) \(timeString)"
        if let date = dateFormatter.date(from: combinedDateTime) {
            self.date = date.timeIntervalSince1970
        } else {
            // Default to now if parsing fails
            self.date = Date().timeIntervalSince1970
        }
    }
}

struct CreateBookingRequest: Codable {
    let fields: CreateBookingFields
}
