import Foundation

final class BoardRoomService {

    func fetchRooms() async throws -> [BoardRoom] {
        let response: BoardRoomsResponse =
            try await APIClient.shared.get(Endpoints.rooms)
        let a = response.records
        print(a)
        return a
    }
}
