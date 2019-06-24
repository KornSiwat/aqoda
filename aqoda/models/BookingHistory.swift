class BookingHistory {
    let customerInfo: CustomerInfo
    let roomId: String

    var isCheckedout: Bool = false
    var floorNumberOfRoom: String {
        return String(roomId.prefix(1))
    }

    init(customerInfo: CustomerInfo, roomId: String) {
        self.customerInfo = customerInfo
        self.roomId = roomId
    }

    func checkout() -> Void {
        isCheckedout = true
    }
}
