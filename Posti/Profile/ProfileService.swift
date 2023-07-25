//
//  ProfileService.swift
//  Posti
//
//  Created by Сергей Ващенко on 20.06.23.
//
import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        let request = makeRequest(token: token)
        let session = URLSession.shared
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
                case .success(let decodedObject):
                    let profile = Profile(data: decodedObject)
                    self?.profile = profile
                    completion(.success(profile))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "\(Constants.defaultBaseURL)" + "/me") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clean() {
        profile = nil
        task?.cancel()
        task = nil
    }
}
