//
//  KeychainWrapper.swift
//
//  Created by Dario Varriale on 21/07/22.
//

import Foundation
import Security

enum KeychainWrapperError: Error {
    case invalidKey
    case failed(status: OSStatus)
    case noDataFromObject
}

class KeychainWrapper {
    
    static let shared = KeychainWrapper()
    private init() {}
    
    /**
     Helper function to setup generic query.
     */
    private func setupQueryDictionary(forKey key: String) -> [String : Any] {
        var queyDict: [String : Any] = [kSecClass as String: kSecClassGenericPassword]
        
        queyDict[kSecAttrAccount as String] = key.data(using: .utf8)
        
        return queyDict
    }
    
    /**
     Use this function to retrieve a `Codable` object from the Keychain.
     
     - Parameters:
        - key: The key for the object.
        - expecting: The explicit `Type` of the object to retrieve to do automatic casting.
     
     - Returns: The object if exist and if the decoding doesn't fail.
     */
    func get<T: Codable>(forKey key: String, expecting: T.Type) throws -> T? {
        guard !key.isEmpty else {
            throw KeychainWrapperError.invalidKey
        }
        
        var queryDict = setupQueryDictionary(forKey: key)
        queryDict[kSecReturnData as String] = kCFBooleanTrue
        queryDict[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var data: AnyObject?
        let status = SecItemCopyMatching(queryDict as CFDictionary, &data)
        
        guard status == errSecSuccess, let data = data as? Data else {
            throw KeychainWrapperError.failed(status: status)
        }
        
        let result: T?
        
        do {
            result = try JSONDecoder().decode(expecting, from: data)
        } catch {
            throw error
        }
        
        return result
    }
    
    /**
     Use this function to set a `Codable` value for a specific key.
     If the object already exists, it will be removed before setting the new value.
     
     - Parameters:
        - value: The new value to set. If null, the object will be removed from the Keychain.
        - key: The key for the object.
     */
    func set<T: Codable>(value: T?, forKey key: String) throws {
        guard !key.isEmpty else {
            throw KeychainWrapperError.invalidKey
        }
        
        guard let value = value else {
            do {
                try remove(forKey: key)
            } catch {
                throw error
            }
            return
        }
        
        guard let data = try? JSONEncoder().encode(value) else {
            throw KeychainWrapperError.noDataFromObject
        }
        
        do {
            try remove(forKey: key)
        } catch {}
        
        var queryDict = setupQueryDictionary(forKey: key)
        queryDict[kSecValueData as String] = data
        
        let status = SecItemAdd(queryDict as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainWrapperError.failed(status: status)
        }
    }
    
    /**
     Use this function to remove an item from the Keychain for a specific key.
     
     - Parameters:
        - key: The key for the object.
     */
    func remove(forKey key: String) throws {
        guard !key.isEmpty else {
            throw KeychainWrapperError.invalidKey
        }
        
        let queryDict = setupQueryDictionary(forKey: key)
        let status = SecItemDelete(queryDict as CFDictionary)
        if status != errSecSuccess {
            throw KeychainWrapperError.failed(status: status)
        }
    }
    
}

