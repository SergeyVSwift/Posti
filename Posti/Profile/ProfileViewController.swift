import UIKit
import Kingfisher
import WebKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
}

final class ProfileViewController: UIViewController {
    
    var presenter: ProfilePresenterProtocol?
    private let profileImage = UIImageView()
    //private var logoutButton: UIButton!
    private let surnameLabel = UILabel()
    private let emailLabel = UILabel()
    private let someTextLabel = UILabel()
    //  private let exitButton = UIButton()
    private let storageToken = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let alertPresenter = AlertPresenter()
    private var profileImageServiceObserver: NSObjectProtocol?
    
   private lazy var logoutButton: UIButton = {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "logoutbutton")!,
            target: self,
            action: #selector(self.didTapLogoutButton))
        logoutButton.tintColor = UIColor(named: "YP Red")
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        return logoutButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        configView()
        makeConstraints()
        updateProfileDetails(profile: profileService.profile!)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func configView() {
        view.addSubview(profileImage)
        view.addSubview(surnameLabel)
        view.addSubview(emailLabel)
        view.addSubview(someTextLabel)
        view.addSubview(logoutButton)
        
        profileImage.image = UIImage(named: "avatar_image")
        surnameLabel.text = "Sergey o_0"
        surnameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        surnameLabel.textColor = .ypWhite
        emailLabel.text = "SergeyVSwift"
        emailLabel.font = .systemFont(ofSize: 13)
        emailLabel.textColor = .ypGray
        someTextLabel.text = "another day"
        someTextLabel.font = .systemFont(ofSize: 13)
        someTextLabel.textColor = .ypWhite
        logoutButton.setImage(UIImage(named: "logoutbutton"), for: .normal)
        logoutButton.tintColor = .ypRed
    }
    
    private func makeConstraints() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        surnameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        someTextLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            surnameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            surnameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emailLabel.topAnchor.constraint(equalTo: surnameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            someTextLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            someTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26),
        ])
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: url,
                                 placeholder: UIImage(named: "avatar_image"),
                                 options: [.processor(processor),.cacheSerializer(FormatIndicatedCacheSerializer.png)])
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
    }
    
    private func setupActions() {
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }
    
    @objc private func didTapLogoutButton() {
        storageToken.clearToken()
        WebViewViewController.clean()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid window configuration") }
        window.rootViewController = SplashViewController()
    }
    
    static func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid Configuration")
            return
        }
        window.rootViewController = SplashViewController()
    }
    
    private func cleanServicesData() {
        ImagesListService.shared.clean()
        ProfileService.shared.clean()
        ProfileImageService.shared.clean()
    }
    
    private func logout() {
        OAuth2TokenStorage().token = nil
        ProfileViewController.clean()
        cleanServicesData()
        switchToSplashViewController()
    }
    
    private func showAlert() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            self.logout()
        }))
        alertController.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
extension ProfileViewController {
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profileService.profile else { return }
        surnameLabel.text = profile.name
        emailLabel.text = profile.loginName
        someTextLabel.text = profile.bio
    }
}

