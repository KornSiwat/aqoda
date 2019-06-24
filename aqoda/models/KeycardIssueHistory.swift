class KeycardIssueHistory {
    let customerInfo: CustomerInfo
    let keycardId: String

    var roomId: String
    var isReturnedKeycard: Bool = false

    init(customerInfo: CustomerInfo, keycardId: String, roomId: String) {
        self.customerInfo = customerInfo
        self.keycardId = keycardId
        self.roomId = roomId
    }

    func returnKeycard() {
        self.isReturnedKeycard = true
    }
}
