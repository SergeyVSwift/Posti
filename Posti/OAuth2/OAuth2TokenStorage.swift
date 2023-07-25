import Foundation
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

enum TokenStorageKeys: String {
    case tokenKey = "BearerToken"
}

final class OAuth2TokenStorage {
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
    
    func clearToken() {
        KeychainWrapper.standard.removeAllKeys()
    }
}


