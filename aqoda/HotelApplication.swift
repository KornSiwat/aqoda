class HotelApplication {
    var service: Service = Service()

    func createHotel(floorCount: Int, roomPerFloorCount: Int) {
        let hotel = service.initializeHotel(floorCount: floorCount,
                                            roomPerFloorCount: roomPerFloorCount)

        print("Hotel created with \(hotel.floorCount) floor(s), \(hotel.roomPerFloorCount) room(s) per floor.")
    }

    func book(name: String, age: Int, roomId: String) {
        do {
            let keycardId = try service.bookByRoomId(name: name, age: age, roomId: roomId)
            let bookingDetail = "Room \(roomId) is booked by \(name) with keycard number \(keycardId)."

            print(bookingDetail)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func bookByFloor(name: String, floorNumber: String) {
        do {
            let (roomIds, keycardIds) = try service.bookByFloorNumber(name: name,
                                                                      floorNumber: floorNumber)
            let bookingDetail = "Room \(roomIds.joined(separator: ", ")) are booked with keycard number \(keycardIds.joined(separator: ", "))"

            print(bookingDetail)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func checkout(name: String, keycardId: String) {
        do {
            let roomId = try service.checkOutByKeycardId(name: name, keycardId: keycardId)
            let checkOutDetail = "Room \(roomId) is checkout."

            print(checkOutDetail)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func checkoutGuestByFloor(floorNumber: String) {
        do {
            let roomIds = try service.checkOutByFloorNumber(floorNumber: floorNumber)
            let checkOutDetail = "Room \(roomIds.joined(separator: ", ")) is checkout."

            print(checkOutDetail)
        } catch let error {
            print(error)
        }
    }

    func getGuestByAge(symbol: String, age: Int) {
        do {
            let roomIds = try service.getGuestNamesByAge(symbol: symbol, age: age)

            print(roomIds.joined(separator: ", "))
        } catch let error {
            print(error)
        }
    }

    func getGuestInRoom(roomId: String) {
        do {
            let guestName = try service.getGuestNameByRoomId(id: roomId)

            print(guestName)
        } catch let error {
            print(error)
        }
    }

    func listGuest() {
        do {
            let guestNames = try service.getGuestNames()

            print(guestNames.joined(separator: ", "))
        } catch let error {
            print(error)
        }
    }

    func listAvailableRoom() {
        do {
            let availableRoomIds = try service.getAvailableRoomIds()

            print(availableRoomIds.joined(separator: ", "))
        } catch let error {
            print(error)
        }
    }

    func listGuestByFloor(floorNumber: String) {
        do {
            let guestNames = try service.getGuestNamesByFloorNumber(floorNumber: floorNumber)

            print(guestNames.joined(separator: ", "))
        } catch let error {
            print(error)
        }
    }
}
