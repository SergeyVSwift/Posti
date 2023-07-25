//
//  UrlResult.swift
//  Posti
//
//  Created by Сергей Ващенко on 24.07.23.
//

import Foundation

struct UrlsResult: Decodable {
    let thumbImageURL: String?
    let largeImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case thumbImageURL = "thumb"
        case largeImageURL = "full"
    }
}
