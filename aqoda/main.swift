func main() throws {
    let hotelApplication = HotelApplication()
    let rawCommands = getCommandsFromInput(inputText: inputs)

    try rawCommands.forEach({ rawCommand in
        let command = try Command.init(command: rawCommand)
        switch command {
        case let .book(name, age, roomId):
            hotelApplication.book(name: name, age: age, roomId: roomId)
        case let .bookByFloor(name, floorNumber):
            hotelApplication.bookByFloor(name: name, floorNumber: floorNumber)
        case let .createHotel(floorCount, roomPerFloorCount):
            hotelApplication.createHotel(floorCount: floorCount, roomPerFloorCount: roomPerFloorCount)
        case let .checkout(name, keycardId):
            hotelApplication.checkout(name: name, keycardId: keycardId)
        case let .checkoutGuestByFloor(floorNumber):
            hotelApplication.checkoutGuestByFloor(floorNumber: floorNumber)
        case .listAvailableRooms:
            hotelApplication.listAvailableRoom()
        case .listGuest:
            hotelApplication.listGuest()
        case let .listGuestByAge(symbol, age):
            hotelApplication.getGuestByAge(symbol: symbol, age: age)
        case let .listGuestByFloor(floorNumber):
            hotelApplication.listGuestByFloor(floorNumber: floorNumber)
        case let .getGuestInRoom(roomId):
            hotelApplication.getGuestInRoom(roomId: roomId)
        default:
            ()
        }
    })
}

func getCommandsFromInput(inputText: String) -> [RawCommand] {
    return inputText.components(separatedBy: "\n")
        .map({ line in
            let words = line.components(separatedBy: " ")
            let name = words.first!
            let params = Array(words.dropFirst())

            return RawCommand(name: name, params: params)
        })
}

do {
    try main()
} catch let error {
    print("Error \(error)")
}
