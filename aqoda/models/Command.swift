enum Command {
    case book(name: String, age: Int, roomId: String)
    case bookByFloor(name: String, floorNumber: String)
    case createHotel(floorCount: Int, roomPerFloorCount: Int)
    case checkout(name: String, keycardId: String)
    case checkoutGuestByFloor(floorNumber: String)
    case getGuestInRoom(roomId: String)
    case listAvailableRooms
    case listGuest
    case listGuestByAge(symbol: String, age: Int)
    case listGuestByFloor(floorNumber: String)
    case unsupport

    init(command: RawCommand) throws {
        switch command.name {
        case "create_hotel":
            guard let floorCount = Int(command.params[0]), let roomPerFloorCount = Int(command.params[1]) else {
                throw MainError.cannotConvertStringToInt
            }

            self = .createHotel(floorCount: floorCount, roomPerFloorCount: roomPerFloorCount)
        case "book":
            let roomId = command.params[0]
            let name = command.params[1]

            guard let age = Int(command.params[2]) else {
                throw MainError.cannotConvertStringToInt
            }

            self = .book(name: name, age: age, roomId: roomId)
        case "book_by_floor":
            let floorNumber = command.params[0]
            let name = command.params[1]

            self = .bookByFloor(name: name, floorNumber: floorNumber)
        case "checkout":
            let keycardId = command.params[0]
            let name = command.params[1]

            self = .checkout(name: name, keycardId: keycardId)
        case "checkout_guest_by_floor":
            let floorNumber = command.params[0]

            self = .checkoutGuestByFloor(floorNumber: floorNumber)
        case "list_available_rooms":
            self = .listAvailableRooms
        case "list_guest":
            self = .listGuest
        case "get_guest_in_room":
            let roomId = command.params[0]

            self = .getGuestInRoom(roomId: roomId)
        case "list_guest_by_age":
            let symbol = command.params[0]

            guard let age = Int(command.params[1]) else {
                throw MainError.cannotConvertStringToInt
            }

            self = .listGuestByAge(symbol: symbol, age: age)
        case "list_guest_by_floor":
            let floorNumber = command.params[0]

            self = .listGuestByFloor(floorNumber: floorNumber)
        default:
            self = .unsupport
        }
    }
}
