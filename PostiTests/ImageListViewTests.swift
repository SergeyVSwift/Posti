//
//  ImageListViewTests.swift
//  PostiTests
//
//  Created by Сергей Ващенко on 25.07.23.
//

import XCTest
@testable import Posti

final class ImageListViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testAddPhotos() {
        let viewController = ImagesListViewControllerSpy()
        let presenter = ImageListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()
        
        let imagesListService = presenter.imagesListService
        XCTAssertNotNil(imagesListService.photos)
    }
}

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: ImagesListViewControllerProtocol?
    var imagesListService: ImagesListService = ImagesListService()
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        return
    }
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageListPresenterProtocol?
    var updateTableViewAnimatedCalled = false
    var photosAdded = false
    
    var photos: [Photo] = []
    
    func updateTableViewAnimated(photos: [Photo]) {
        updateTableViewAnimatedCalled = true
    }
}
