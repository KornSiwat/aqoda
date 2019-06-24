class Customer {
    let name: String
    let age: Int

    var keycards: [String: Keycard]

    init(name: String, age: Int, keycards: [String: Keycard]? = nil) {
        self.name = name
        self.age = age
        self.keycards = keycards ?? [:]
    }

    func haveKeycardWithId(id: String) -> Bool {
        guard let _ = keycards[id] else {
            return false
        }

        return true
    }

    func getKeycardWithId(id: String) throws -> Keycard {
        guard let keycard = keycards[id] else {
            throw CustumerError.keycardNotFound
        }

        return keycard
    }

    func receiveKeycard(keycard: Keycard) {
        self.keycards[keycard.id] = keycard
    }

    func returnKeycardById(id: String) throws -> Keycard {
        guard let keycard = self.keycards.removeValue(forKey: id) else {
            throw CustumerError.returnKeycardNotFound
        }

        return keycard
    }
}
