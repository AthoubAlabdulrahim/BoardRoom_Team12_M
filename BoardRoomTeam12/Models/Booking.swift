//
//  Booking.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 13/07/1447 AH.
//
// Models/Booking.swift
import Foundation

// Note:
// The response/record/fields models are defined in BookingResponse.swift:
// - BookingResponse
// - BookingRecord
// - BookingFields
// This file only keeps the models used for creating new bookings.

// MARK: - For creating new bookings (Adjust based on your needs)
struct CreateBookingFields: Codable {
    // Use the exact field names that your backend expects
    let employee_id: String
    let boardroom_id: String
    let date: Double  // Unix timestamp (seconds)
    
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
        if let parsedDate = dateFormatter.date(from: combinedDateTime) {
            self.date = parsedDate.timeIntervalSince1970
        } else {
            // Default to now if parsing fails
            self.date = Date().timeIntervalSince1970
        }
    }
}

struct CreateBookingRequest: Codable {
    let fields: CreateBookingFields
}

