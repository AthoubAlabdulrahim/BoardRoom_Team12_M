//
//  Models.swift
//  BoardRoomTeam12
//
//  Created by Jamilah Jaber Hazazi on 03/07/1447 AH.
//

import Foundation

struct Room: Identifiable {
    let id = UUID()
    let name: String
    let floor: String
    let capacity: Int
    let imageName: String
    let isAvailable: Bool
}
