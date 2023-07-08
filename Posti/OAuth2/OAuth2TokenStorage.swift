import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let supplierToken = "Token"
    static let shared = OAuth2TokenStorage()
    
    static var token: String? {
        set {
            guard let token = newValue else {
                KeychainWrapper.standard.removeObject(forKey: supplierToken)
                return
            }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: supplierToken)
            guard isSuccess else {
                fatalError("Код не сохранен")
            }
        }
        get {
            KeychainWrapper.standard.string(forKey: supplierToken)
        }
    }
}



