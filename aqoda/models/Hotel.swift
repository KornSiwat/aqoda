class Hotel {
    typealias History = (bookingHistory: BookingHistory, keycardIssueHistory: KeycardIssueHistory)

    let floorCount: Int
    let roomPerFloorCount: Int
    let totalRoomCount: Int

    var bookingHistories: [BookingHistory] = []
    var keycardIssueHistories: [KeycardIssueHistory] = []
    var rooms: [String: Room] = [:]
    var keycards: [Keycard] = []
    var customers: [String: Customer] = [:]

    var availableRooms: [Room] {
        return rooms.values.filter { !$0.isBooked }
    }

    var firstAvailableKeycard: Keycard {
        return keycards.sorted { $0.id < $1.id }.first { !$0.isBorrowed }!
    }

    var isFull: Bool {
        return availableRooms.count == 0
    }

    var notCheckedOutBookingHistories: [BookingHistory] {
        return bookingHistories.filter { !$0.isCheckedout }
    }

    var notReturnedKeycard: [KeycardIssueHistory] {
        return keycardIssueHistories.filter { !$0.isReturnedKeycard }
    }

    init(floorCount: Int, roomPerFloorCount: Int) {
        self.floorCount = floorCount
        self.roomPerFloorCount = roomPerFloorCount
        totalRoomCount = floorCount * roomPerFloorCount
        setupRooms(floorCount: floorCount, roomPerFloorCount: roomPerFloorCount)
        setupKeycards(totalRoomCount: totalRoomCount)
    }

    func bookAndCheckIn(customer: Customer, roomId: String) throws -> History {
        let bookingHistory = try book(customer: customer, roomId: roomId)
        let keycardIssueHistory = checkIn(customer: customer, bookingHistory: bookingHistory)

        return (bookingHistory, keycardIssueHistory)
    }

    func bookAndCheckInByFloorNumber(customer: Customer, floorNumber: String) throws -> [History] {
        guard try isFloorAvailable(floorNumber: floorNumber) else {
            throw HotelError.floorNotAvailable("Cannot book floor \(floorNumber) for \(customer.name).")
        }

        let roomIds = try getRoomsByFloorNumber(floorNumber: floorNumber).map { $0.id }

        return try roomIds.map { try bookAndCheckIn(customer: customer, roomId: $0) }

    }

    func checkOutByCustomer(customer: Customer, keycardId: String) throws {
        let keycard = try customer.returnKeycardById(id: keycardId)
        let room = try getRoomById(id: keycard.roomId!)

        try clearRoom(room: room)
        try clearKeycard(keycard: keycard)
    }

    func checkOutByFloorNumber(floorNumber: String) throws {
        let rooms = try getBookedRoomsByFloorNumber(floorNumber: floorNumber)
        let keycardIds = try getBorrowedKeycardsByFloorNumber(floorNumber: floorNumber)
            .map { $0.id }
        let keycards = try keycardIds.map { try getKeycardFromCustomerByKeycardId(id: $0) }

        try rooms.forEach { try clearRoom(room: $0) }
        try keycards.forEach { try clearKeycard(keycard: $0) }
    }

    func getBookedRoomsByFloorNumber(floorNumber: String) throws -> [Room] {
        let bookedRooms = try getRoomsByFloorNumber(floorNumber: floorNumber)
            .filter { $0.isBooked }

        return bookedRooms
    }

    func getBookingHistoryByRoomId(id: String) throws -> BookingHistory {
        guard let bookingHistory = (bookingHistories.first { $0.roomId == id }) else {
            throw HotelError.bookingHistoryNotFound
        }

        return bookingHistory
    }

    func getKeycardByKeycardId(id: String) throws -> Keycard {
        guard let keycard = (keycards.first { $0.id == id }) else {
            throw HotelError.keycardNotFound
        }

        return keycard
    }

    private func addCustomer(customer: Customer) {
        guard let _ = customers[customer.name] else {
            customers[customer.name] = customer

            return
        }
    }

    private func book(customer: Customer, roomId: String) throws -> BookingHistory {
        let customerInfo = CustomerInfo(name: customer.name, age: customer.age)
        let room = try getRoomById(id: roomId)
        let bookingHistory = BookingHistory(customerInfo: customerInfo, roomId: roomId)

        guard !isFull else { throw HotelError.fullyBooked }
        guard !room.isBooked else {
            let currentCustomerName = try getBookingHistoryByRoomId(id: roomId).customerInfo.name

            throw HotelError.wantedRoomNotAvailable("""
                Cannot book room \(roomId) for \(customer.name), The room is currently booked by \(currentCustomerName).
                """)
        }

        addCustomer(customer: customer)

        room.book()

        bookingHistories.append(bookingHistory)

        return bookingHistory
    }

    private func checkIn(customer: Customer, bookingHistory: BookingHistory) -> KeycardIssueHistory {
        let (keycard, keycardIssueHistory) = issueKeycard(bookingHistory: bookingHistory)

        customer.receiveKeycard(keycard: keycard)

        return keycardIssueHistory
    }

    private func clearRoom(room: Room) throws {
        room.makeAvailable()
        try getBookingHistoryByRoomId(id: room.id).checkout()
    }

    private func clearKeycard(keycard: Keycard) throws {
        keycard.deleteData()
        try getKeycardIssueHistoryByKeycardId(id: keycard.id).returnKeycard()
    }

    private func getKeycardFromCustomerByKeycardId(id: String) throws -> Keycard {
        guard let customer = (customers.values.first { $0.haveKeycardWithId(id: id) }) else {
            throw HotelError.customerWithWantedKeycardIdNotFound
        }

        let keycard = try customer.returnKeycardById(id: id)

        return keycard
    }

    private func getRoomById(id: String) throws -> Room {
        guard let room = rooms[id] else {
            throw HotelError.roomNotFound
        }

        return room
    }

    private func getRoomsByFloorNumber(floorNumber: String) throws -> [Room] {
        let rooms = self.rooms.values.filter { $0.floorNumber == floorNumber }

        if rooms.count == 0 { throw HotelError.roomNotFound }

        return rooms
    }

    private func getBookingHistoryByFloorNumber(floorNumber: String) throws -> BookingHistory {
        guard let bookingHistory = (bookingHistories.first { $0.floorNumberOfRoom == floorNumber }) else {
            throw HotelError.bookingHistoryNotFound
        }

        return bookingHistory
    }

    private func getKeycardIssueHistoryByKeycardId(id: String) throws -> KeycardIssueHistory {
        guard let keycardIssueHistory = (keycardIssueHistories.first { $0.keycardId == id }) else {
            throw HotelError.keycardIssueHistoryNotFound
        }

        return keycardIssueHistory
    }

    private func getBorrowedKeycardsByFloorNumber(floorNumber: String) throws -> [Keycard] {
        let keycards = self.keycards.filter { $0.isBorrowed }
            .filter { $0.floorNumberOfRoom == floorNumber }

        if keycards.count == 0 { throw HotelError.borrowedKeycardNotFound }

        return keycards
    }

    private func isFloorAvailable(floorNumber: String) throws -> Bool {
        return try getBookedRoomsByFloorNumber(floorNumber: floorNumber).count == 0
    }

    private func issueKeycard(bookingHistory: BookingHistory) -> (Keycard, KeycardIssueHistory) {
        let keycard = firstAvailableKeycard

        keycard.writeData(roomId: bookingHistory.roomId)

        let keycardIssueHistory = KeycardIssueHistory(customerInfo: bookingHistory.customerInfo,
                                                      keycardId: keycard.id,
                                                      roomId: keycard.roomId!)

        keycardIssueHistories.append(keycardIssueHistory)

        return (keycard, keycardIssueHistory)
    }

    private func setupRooms(floorCount: Int, roomPerFloorCount: Int) {
        let rooms: [Room] = (1...floorCount).flatMap { floorNumber in
            (1...roomPerFloorCount).map { roomNumber in
                let id = "\(floorNumber)0\(roomNumber)"

                return Room(id: id)
            }
        }

        self.rooms = Dictionary(uniqueKeysWithValues: rooms.map { ($0.id, $0) })
    }

    private func setupKeycards(totalRoomCount: Int) {
        let keycards: [Keycard] = (1...totalRoomCount)
            .map { id in Keycard(id: "\(id)") }

        self.keycards = keycards
    }

}
