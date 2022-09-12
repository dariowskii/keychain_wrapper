import Foundation

// Expand it according to your needs!
enum UserDefaultsKey: String {
    case accessToken
}

@propertyWrapper
struct KeychainItem<T: Codable> {
    private var _key: UserDefaultsKey
    
    var wrappedValue: T? {
        get {
            KeychainWrapper.shared.get(forKey: _key.rawValue)
        }
        set {
            try? KeychainWrapper.shared.set(value: newValue, forKey: _key.rawValue)
        }
    }
    
    init(key: UserDefaultsKey) {
        _key = key
    }
}
