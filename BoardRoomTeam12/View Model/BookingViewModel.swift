//
//  HomeViewModel.swift
//  BoardRoomTeam12
//
//  Created by Jamilah Jaber Hazazi on 03/07/1447 AH.
//

import Foundation
import Combine

final class BookingViewModel: ObservableObject {
    
    @Published var rooms: [Room] = [
        Room(name: "Creative Space",
             floor: "Floor 5",
             capacity: 1,
             imageName: "room1",
             isAvailable: true),
        
        Room(name: "Ideation Room",
             floor: "Floor 3",
             capacity: 16,
             imageName: "room2",
             isAvailable: false),
        
        Room(name: "Inspiration Room",
             floor: "Floor 1",
             capacity: 18,
             imageName: "room3",
             isAvailable: false)
    ]
    
}
