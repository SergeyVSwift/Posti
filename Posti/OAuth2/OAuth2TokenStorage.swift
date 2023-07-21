import UIKit
import SwiftKeychainWrapper

class OAuth2TokenStorage {

    var token: String? {
        get {
           return KeychainWrapper.standard.string(forKey: "Auth token")
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: "Auth token")
                let flag = token.count > 0
                UserDefaults.standard.set(flag, forKey: "tokenFlag")
            }
        }
    }
}

