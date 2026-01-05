import SwiftUI

struct LoginViewWrapper: View {

    @Binding var isLoggedIn: Bool

    var body: some View {
        LoginView()
            .onChange(of: UserSession.shared.isLoggedIn) { _, newValue in
                isLoggedIn = newValue
            }
    }
}
