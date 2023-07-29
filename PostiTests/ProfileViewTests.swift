//
//  ProfileViewTests.swift
//  PostiTests
//
//  Created by Сергей Ващенко on 25.07.23.
//

import XCTest
@testable import Posti

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled: Bool = true
    var didTaPLogoutButton: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

final class ProfileViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
