//
//  Photo.swift
//  Posti
//
//  Created by Сергей Ващенко on 24.07.23.
//

import Foundation

struct Photo {
    let id: String
    let width: CGFloat
    let height: CGFloat
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String?
    let largeImageURL: String?
    let isLiked: Bool
}
