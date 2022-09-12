# keychain_wrapper

A simple KeychainWrapper to get, set, remove any `Codable` object from Keychain!

## Examples

You can `get` a value in this way:
```swift
do {
    let myPassword = try KeychainWrapper.shared.get(forKey: "myPasswordKey", expecting: String.self)
} catch {
    // handle error
}
// ...
// or without handling error
let myPassword: String? = KeychainWrapper.shared.get(forKey: "myPasswordKey")
```

You can `set` a new value for a specific key in this way:
```swift
let myObject: Codable = MyObject()

do {
    try KeychainWrapper.shared.set(value: myObject, forKey: "myObjectKey")
} catch {
    // handle error
}
```

You can `remove` a value for a specific key in this way:
```swift
do {
    try KeychainWrapper.shared.remove(forKey: "myObjectKey")
} catch {
    // handle error
}
```

You can remove all the stored values in this way:
```swift
do {
    try KeychainWrapper.shared.deleteAll()
} catch {
    // handle error
}
```

---

Made with ❤️ from [dariowskii](https://www.linkedin.com/in/dario-varriale/)
