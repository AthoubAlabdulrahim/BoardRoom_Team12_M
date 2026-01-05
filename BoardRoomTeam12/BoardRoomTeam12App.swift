//
//  BoardRoomTeam12App.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//

import SwiftUI

@main
struct BoardRoomTeam12App: App {

    @State private var isLoggedIn = UserSession.shared.isLoggedIn

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView(isLoggedIn: $isLoggedIn)
            }
        }
    }
}
