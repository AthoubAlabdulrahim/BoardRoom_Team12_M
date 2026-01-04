//
//  HomeViewModel.swift
//  BoardRoomTeam12
//
//  Created by Jamilah Jaber Hazazi on 03/07/1447 AH.
//
import Foundation
import Combine

@MainActor
class BookingViewModel: ObservableObject {
    @Published var rooms: [RoomRecord] = []
    @Published var myBookings: [BookingRecord] = []
    @Published var isLoading = false
    
    private let roomService = DefaultRoomService()
    private let bookingService = DefaultBookingService()
    
    init() {
        Task { await loadData() }
    }
    
    func loadData() async {
        isLoading = true
        // جلب معرف الموظف الذي سجل دخوله من UserDefaults
        let currentEmployeeID = UserDefaults.standard.string(forKey: "current_employee_id") ?? ""
        
        do {
            // جلب البيانات من الـ API بشكل متوازي
            async let fetchedRooms = roomService.fetchRooms()
            async let fetchedAllBookings = bookingService.fetchAllBookings()
            
            let allRooms = try await fetchedRooms
            let allBookings = try await fetchedAllBookings
            
            self.rooms = allRooms
            
            // 🔥 الفلترة: نأخذ فقط الحجوزات التي تخص الموظف الحالي
            self.myBookings = allBookings.filter { $0.fields.employeeID == currentEmployeeID }
            
        } catch {
            print("❌ Error loading data: \(error)")
        }
        isLoading = false
    }
}
