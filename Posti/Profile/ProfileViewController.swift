import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private let profileImage = UIImageView()
    private let surnameLabel = UILabel()
    private let emailLabel = UILabel()
    private let someTextLabel = UILabel()
    private let exitButton = UIButton()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        view.addSubview(exitButton)
        
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
        exitButton.setImage(UIImage(named: "logoutbutton"), for: .normal)
        exitButton.tintColor = .ypRed
        
    }
    
    private func makeConstraints() {
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        surnameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        someTextLabel.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        
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
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -26)
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
}

extension ProfileViewController {
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profileService.profile else { return }
        surnameLabel.text = profile.name
        emailLabel.text = profile.loginName
        someTextLabel.text = profile.bio
    }
}

