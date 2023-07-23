//
//  UserResults.swift
//  Posti
//
//  Created by Сергей Ващенко on 24.07.23.
//

import UIKit

struct UserResult: Codable {
    let profileImage: [String:String]
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
