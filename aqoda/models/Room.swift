class Room {
    let id: String

    var isBooked: Bool = false
    var floorNumber: String {
        return String(id.prefix(1))
    }

    init(id: String) {
        self.id = id
    }

    func book() {
        isBooked = true
    }

    func makeAvailable() {
        isBooked = false
    }
}
