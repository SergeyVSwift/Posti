import UIKit

//MARK: - Key
let accessKey = "3OAZUBSyccZg3_EPIdR_EDjfziLvnCZrEOXO2LQ4xyc"
let secretKey = "oSSJeGcgGev9Ou8ODtARWB0j4FULj7iJN9DdhOUqOJk"
let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
let accessScope = "public+read_user+write_likes"
let defaultBaseURL = URL(string: "https://api.unsplash.com")!

enum Constants {
    static let accessKey = "3OAZUBSyccZg3_EPIdR_EDjfziLvnCZrEOXO2LQ4xyc"
    static let secretKey = "oSSJeGcgGev9Ou8ODtARWB0j4FULj7iJN9DdhOUqOJk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthString = "https://unsplash.com/oauth/authorize"
    static let oauthString = "https://unsplash.com/oauth/token"
    static let tokenKey = "Auth token"
}
