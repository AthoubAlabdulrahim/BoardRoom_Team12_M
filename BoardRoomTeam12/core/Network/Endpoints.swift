import Foundation

enum Endpoints {

    static var employees: URL {
        URL(string: Secrets.employeesURLString)!
    }

    static var rooms: URL {
        URL(string: Secrets.roomsURLString)!
    }

    static var bookings: URL {
        URL(string: Secrets.bookingsURLString)!
    }

    static func booking(id: String) -> URL {
        URL(string: Secrets.bookingsURLString + "/\(id)")!
    }
}
