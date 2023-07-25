//
//  ImagesListService.swift
//  Posti
//
//  Created by Сергей Ващенко on 19.07.23.
//

import UIKit

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private let perPage = "10"
    private var task: URLSessionTask?
    static let DidChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    static let shared = ImagesListService()
    private let storageToken = OAuth2TokenStorage()
    private let dateFormatter = ISO8601DateFormatter()
    private let urlSession = URLSession.shared

    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let page = lastLoadedPage == nil
        ? 1
        : lastLoadedPage! + 1
        guard let request = photoRequest(page: String(page), perPage: perPage) else { return }
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                guard let self else { return }
                self.task = nil
                switch result {
                case .success(let photoResults):
                    for photoResult in photoResults {
                        self.photos.append(self.convert(photoResult))
                    }
                    self.lastLoadedPage = page
                    NotificationCenter.default
                        .post(
                            name: ImagesListService.DidChangeNotification,
                            object: self,
                            userInfo: ["Images" : self.photos])
                case .failure(_):
                    break
                }
            }
        }
        self.task = task
        task.resume()
    }
         
    private func photoRequest(page: String, perPage: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com") else { return nil }
        var request = URLRequest.makeHTTPRequest(
            path: "/photos?page=\(page)&&per_page=\(perPage)",
            httpMethod: "GET",
            baseURL: url)
        if let token = OAuth2TokenStorage().token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
    
    private func convert(_ photoResult: PhotoResult) -> Photo {
        Photo(id: photoResult.id,
              width: CGFloat(photoResult.width),
              height: CGFloat(photoResult.height),
              createdAt: self.dateFormatter.date(from:photoResult.createdAt ?? ""),
              welcomeDescription: photoResult.welcomeDescription,
              thumbImageURL: photoResult.urls?.thumbImageURL,
              largeImageURL: photoResult.urls?.largeImageURL,
              isLiked: photoResult.isLiked ?? false)
    }
    
    func updatePhotos(_ photos: [Photo]) {
        self.photos = photos
    }
    
    func clean() {
        photos = []
        lastLoadedPage = nil
        task?.cancel()
        task = nil
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = storageToken.token else { return }
        var request: URLRequest?
        if isLike {
            request = deleteLikeRequest(token, photoId: photoId)
        } else {
            request = postLikeRequest(token, photoId: photoId)
        }
        guard let request = request else { return }
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<LikePhotoResult, Error>) in
            guard let self = self else { return }
            self.task = nil
            switch result {
            case .success(let photoResult):
                let isLiked = photoResult.photo?.isLiked ?? false
                if let index = self.photos.firstIndex(where: { $0.id == photoResult.photo?.id }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        width: photo.width,
                        height: photo.height,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: isLiked
                    )
                    self.photos = self.withReplaced(itemAt: index, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func postLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        var requestPost = URLRequest.makeHTTPRequest(
            path: "photos/\(photoId)/like",
            httpMethod: "POST",
            baseURL: URL(string: "\(Constants.defaultBaseURL)")!)
        requestPost.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return requestPost
    }
    
    private func withReplaced(itemAt: Int, newValue: Photo) -> [Photo] {
        photos.replaceSubrange(itemAt...itemAt, with: [newValue])
        return photos
    }
    
    private func deleteLikeRequest(_ token: String, photoId: String) -> URLRequest? {
        var requestDelete = URLRequest.makeHTTPRequest(
            path: "photos/\(photoId)/like",
            httpMethod: "DELETE",
            baseURL: URL(string: "\(Constants.defaultBaseURL)")!)
        requestDelete.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return requestDelete
    }
}
