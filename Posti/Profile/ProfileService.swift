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
    private var lastProfileCode: String?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private enum NetworkError: Error {
        case codeError
    }
    
// MARK: - fetchProfile
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastProfileCode == token { return }
        task?.cancel()
        lastProfileCode = token
        
        let request = makeRequest(token: token)
        
        let session = URLSession.shared
        task? = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            self.task = nil
            switch result {
            case .success(let profileResult):
               let profile = Profile(
                    username: profileResult.username,
                    name: profileResult.first_name + " " + profileResult.last_name,
                    loginName: "@" + profileResult.username,
                    bio: profileResult.bio ?? ""
                )
                self.profile = profile
                completion(.success(profile))
            case .failure(_):
                completion(.failure(NetworkError.codeError))
                self.lastProfileCode = nil
                return
            }
        }
        task?.resume()
    }
    
    private func makeRequest(token: String) -> URLRequest {
        guard let url = URL(string: "\(Constants.defaultBaseURL)" + "/me") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Structs

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

struct ProfileResult: Decodable {
    let username: String
    let first_name: String
    let last_name: String
    let bio: String?
}
