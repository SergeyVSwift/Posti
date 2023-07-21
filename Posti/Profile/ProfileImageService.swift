import UIKit

final class ProfileImageService{
    
    static let shared = ProfileImageService()
    private (set) var avatarURL: String?
    private var urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let url = URL(string: "/users/\(username)", relativeTo: defaultBaseURL) else {
            print("Wrong URL")
            return
        }
        
        guard let token = OAuth2TokenStorage().token else {return}
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
            
            switch result{
            case .success(let url):
                
                guard let avatarURL = url.profileImage["small"] else {return}
                self.avatarURL = avatarURL
                
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": avatarURL])
                
                completion(.success(avatarURL))
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
        
        task?.resume()
    }
    
    
    struct UserResult: Codable {
        var profileImage: [String: String]
        
        enum CodingKeys: String, CodingKey{
            case profileImage = "profile_image"
        }
    }
}
