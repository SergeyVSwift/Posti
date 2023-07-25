//
//  ProfileImage.swift
//  Posti
//
//  Created by Сергей Ващенко on 24.07.23.
//

import Foundation

struct ProfileImage: Codable {
    let profileImage: [String:String]
    
    init(decodedData: UserResult) {
        self.profileImage = decodedData.profileImage
    }
}
