class Keycard {
    let id: String

    var roomId: String?
    var isBorrowed: Bool = false
    var floorNumberOfRoom: String {
        return String(roomId!.prefix(1))
    }

    init(id: String) {
        self.id = id
    }

    func writeData(roomId: String) {
        self.roomId = roomId
        self.isBorrowed = true
    }

    func deleteData() {
        self.roomId = nil
        self.isBorrowed = false
    }
}
