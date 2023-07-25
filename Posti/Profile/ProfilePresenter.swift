//
//  ProfilePresenter.swift
//  Posti
//
//  Created by Сергей Ващенко on 20.07.23.
//

import Foundation
import WebKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var tokenStorage: OAuth2TokenStorageProtocol { get set }
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var tokenStorage: OAuth2TokenStorageProtocol
    weak var view: ProfileViewControllerProtocol?
    
    init(tokenStorage: OAuth2TokenStorageProtocol) {
        self.tokenStorage = tokenStorage
    }
    
    func logout() {
        tokenStorage.token = nil
        clean()
    }
    
    func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
