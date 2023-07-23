/*import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "token"

    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: tokenKey)
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}*/

import Foundation
import SwiftKeychainWrapper

enum TokenStorageKeys: String {
    case tokenKey = "BearerToken"
}

class OAuth2TokenStorage {
    private let keychain = KeychainWrapper.standard

    var token: String? {
        get {
            return keychain.string(forKey: TokenStorageKeys.tokenKey.rawValue)
        }
        
        set(newValue) {
            if let token = newValue {
                keychain.set(token, forKey: TokenStorageKeys.tokenKey.rawValue)
                
            } else {
                keychain.removeObject(forKey: TokenStorageKeys.tokenKey.rawValue)
            }
        }
    }
}


