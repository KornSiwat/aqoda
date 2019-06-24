class Service {
    var hotel: Hotel?

    func bookByRoomId(name: String, age: Int, roomId: String) throws -> String {
        let customer = getOrCreateCustomer(name: name, age: age)
        let (_, keyCardIssueHistory) = try getHotel().bookAndCheckIn(customer: customer,
                                                                     roomId: roomId)

        return keyCardIssueHistory.keycardId
    }

    func bookByFloorNumber(name: String, floorNumber: String) throws -> ([String], [String]) {
        let customer = getOrCreateCustomer(name: name)
        let histories = try getHotel().bookAndCheckInByFloorNumber(customer: customer,
                                                                   floorNumber: floorNumber)

        return histories.reduce(([], []), { (acc, history) in
            let (bookingHistory, keycardIssueHistory) = history

            return (acc.0 + [bookingHistory.roomId], acc.1 + [keycardIssueHistory.keycardId])
        })
    }

    func checkOutByKeycardId(name: String, keycardId: String) throws -> String {
        let customer = try getCheckOutCustomer(name: name, keycardId: keycardId)
        guard let roomId = try customer.getKeycardWithId(id: keycardId).roomId else {
            throw ServiceError.wantedCheckOutKeycardNotFound
        }

        try getHotel().checkOutByCustomer(customer: customer, keycardId: keycardId)

        return roomId
    }

    func checkOutByFloorNumber(floorNumber: String) throws -> [String] {
        let roomIds = try getHotel().getBookedRoomsByFloorNumber(floorNumber: floorNumber)
            .map { $0.id }

        try getHotel().checkOutByFloorNumber(floorNumber: floorNumber)

        return roomIds
    }

    func getAvailableRoomIds() throws -> [String] {
        return try getHotel().availableRooms.map { $0.id }
    }

    func getCustomerByName(name: String) throws -> Customer {
        guard let customer = try getHotel().customers[name] else {
            throw ServiceError.customerNotFound
        }

        return customer
    }

    func getGuestNames() throws -> [String] {
        return try getHotel().notCheckedOutBookingHistories.map { $0.customerInfo.name }
    }

    func getGuestNamesByAge(symbol: String, age: Int) throws -> [String] {
        let filterCondition = getAgeFilterConditionBySymbol(symbol: symbol, age: age)

        return try getGuestNamesByCondition(filterFunction: filterCondition)
    }

    func getGuestNamesByFloorNumber(floorNumber: String) throws -> [String] {
        let filterCondition = { (bookingHistory: BookingHistory) -> Bool in
            return bookingHistory.floorNumberOfRoom == floorNumber
        }

        return try getGuestNamesByCondition(filterFunction: filterCondition)
    }

    func getGuestNameByRoomId(id: String) throws -> String {
        let bookingHistory = try getHotel().notCheckedOutBookingHistories.first { $0.roomId == id }

        guard let guestName = bookingHistory?.customerInfo.name else {
            throw ServiceError.customerNotFound
        }

        return guestName
    }

    func initializeHotel(floorCount: Int, roomPerFloorCount: Int) -> Hotel {
        hotel = Hotel(floorCount: floorCount, roomPerFloorCount: roomPerFloorCount)

        return hotel!
    }

    private func getAgeFilterConditionBySymbol(symbol: String, age: Int) -> ((BookingHistory) -> Bool) {
        switch symbol {
        case "<":
            return { bookingHistory in
                let customerAge = bookingHistory.customerInfo.age

                return customerAge < age
            }
        case "=":
            return { bookingHistory in
                let customerAge = bookingHistory.customerInfo.age

                return customerAge == age
            }
        case ">":
            return { bookingHistory in
                let customerAge = bookingHistory.customerInfo.age

                return customerAge > age
            }
        default:
            return { _ in return true }
        }
    }

    private func getGuestNamesByCondition(filterFunction: (BookingHistory) -> Bool) throws -> [String] {
        let bookingHistories = try getHotel().notCheckedOutBookingHistories

        return Array(Set(bookingHistories.filter(filterFunction).map { $0.customerInfo.name }))
    }

    private func getHotel() throws -> Hotel {
        guard let hotel = hotel else {
            throw ServiceError.hotelNotFound
        }

        return hotel
    }

    private func getOrCreateCustomer(name: String, age: Int? = nil) -> Customer {
        do {
            let customer = try getCustomerByName(name: name)

            return customer
        } catch {
            return Customer(name: name, age: age!)
        }
    }

    private func getCheckOutCustomer(name: String, keycardId: String) throws -> Customer {
        let keycard = try getHotel().getKeycardByKeycardId(id: keycardId)
        let bookingHistory = try getHotel().getBookingHistoryByRoomId(id: keycard.roomId!)
        let customerName = bookingHistory.customerInfo.name
        let nameMatchWithCustomerName = customerName == name

        guard nameMatchWithCustomerName else {
            throw ServiceError.nameNotMatchToCheckOut("Only \(customerName) can checkout with keycard number \(keycardId).")
        }

        return try getCustomerByName(name: name)
    }
}
