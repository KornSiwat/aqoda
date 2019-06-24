import Foundation

enum MainError: Error {
    case cannotConvertStringToInt
}

enum ServiceError: LocalizedError {
    case hotelNotFound
    case customerNotFound
    case nameNotMatchToCheckOut(String)
    case wantedCheckOutKeycardNotFound

    var errorDescription: String? {
        switch self {
        case .nameNotMatchToCheckOut(let message):
            return "\(message)"
        default:
            return "\(self)"
        }
    }
}

enum HotelError: LocalizedError {
    case customerWithWantedKeycardIdNotFound
    case bookedRoomNotFound
    case borrowedKeycardNotFound
    case bookingHistoryNotFound
    case floorNotAvailable(String)
    case fullyBooked
    case keycardNotFound
    case keycardIssueHistoryNotFound
    case roomNotFound
    case wantedRoomNotAvailable(String)

    var errorDescription: String? {
        switch self {
        case .floorNotAvailable(let message):
            return "\(message)"
        case .wantedRoomNotAvailable(let message):
            return "\(message)"
        default:
            return "\(self)"
        }
    }
}

enum CustumerError: Error {
    case keycardNotFound
    case returnKeycardNotFound
}

