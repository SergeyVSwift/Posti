import UIKit
import ProgressHUD
import SwiftKeychainWrapper


// MARK: - SplashViewController
final class SplashViewController: UIViewController {
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oAuth2Service = OAuth2Service()
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var isFirstAppear = true
    
    private lazy var splashScreen: UIImageView = {
        let splashScreen = UIImageView()
        splashScreen.translatesAutoresizingMaskIntoConstraints = false
        splashScreen.image = UIImage(named: "LaunchLogo_Vector")
        return splashScreen
    } ()
    
    private func setupConstraints() {
        view.addSubview(splashScreen)
        splashScreen.heightAnchor.constraint(equalToConstant: 70).isActive = true
        splashScreen.widthAnchor.constraint(equalToConstant: 70).isActive = true
        splashScreen.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        splashScreen.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(identifier: "AuthViewController") as? AuthViewController
       else { return }
       authViewController.delegate = self
       authViewController.modalPresentationStyle = .fullScreen
       self.present(authViewController, animated: true)
   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        setupConstraints()
    }
    
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        
        UIBlockingProgressHUD.show()
        
        oAuth2Service.fetchAuthToken(code: code) {[weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let authToken):
                print("TOKEN: \(authToken)")
                self.fetchProfileSplash(token: authToken)
                
            case .failure(let error):
                
                UIBlockingProgressHUD.dismiss()
                
                let alert = UIAlertController(title: "Что-то пошло не так(",
                                              message: "Не удалось войти в систему",
                                              preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Ok", style: .default)
                
                alert.addAction(action)
                vc.present(self, animated: true)
                
                print(error)
            }
        }
    }
    
    private func fetchProfileSplash(token: String){
        
        profileService.fetchProfile(token) { [weak self] profileInfo  in
                
                guard let self = self else {return}
                
                switch profileInfo{
                case .success(let profile):
                    
                    ProfileImageService.shared.fetchProfileImageURL(username: profile.username) {urlResult in
                        switch urlResult {
                        case .success(let url):
                            return
                        case .failure(let error):
                            return
                        }
                    }
                    
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    print(error)
                }
        }
        
    }
}
