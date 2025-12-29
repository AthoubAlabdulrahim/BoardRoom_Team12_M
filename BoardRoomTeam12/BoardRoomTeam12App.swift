//
//  BoardRoomTeam12App.swift
//  BoardRoomTeam12
//
//  Created by Athoub Alabdulrahim on 03/07/1447 AH.
//

import SwiftUI

@main
struct BoardRoomTeam12App: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LoginView()
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button for all pushed views
        }
    }
}
