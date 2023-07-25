//
//  Profile.swift
//  Posti
//
//  Created by Сергей Ващенко on 24.07.23.
//

import Foundation

struct Profile: Codable {
    var userName: String
    var name: String
    var loginName: String
    var bio: String?
    
    init(data: ProfileResult) {
        self.userName = data.username
        self.name = (data.firstName) + " " + (data.lastName ?? "")
        self.loginName = "@" + (data.username)
        self.bio = data.bio
    }
}
