import SwiftUI

struct RootView: View {

    @Binding var isLoggedIn: Bool

    var body: some View {
        if isLoggedIn {
            HomeView()
        } else {
            LoginViewWrapper(isLoggedIn: $isLoggedIn)
        }
    }
}
