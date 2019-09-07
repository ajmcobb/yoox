//
//  CatalogueViewControllerTests.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import XCTest

@testable import Yoox

// MARK: - Setup

class CatalogueViewControllerTests: XCTestCase {

    var sut: CatalogueViewController!
    var dependenciesHelper: DependenciesHelper!
    var mockDataStorage: MockStorage!

    override func setUp() {
        super.setUp()
        mockDataStorage = MockStorage()
        dependenciesHelper = DependenciesHelper()
        sut = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CatalogueViewController") as? CatalogueViewController
        let viewModel = CatalogueViewModel(dependencies: dependenciesHelper.dependencies, dispatching: MockDispatcher(), fileStorage: MockStorage(), dataStorage: mockDataStorage)
        sut.viewModel = viewModel
    }

    override func tearDown() {
        sut = nil
        dependenciesHelper = nil
        mockDataStorage = nil
        super.tearDown()
    }

    func loadViewOnSUT() {
        let data = try! JSONDecoder().read(fromJSON: "validCatalogueItems", keyPath: "", bundle: .testBundle)
        dependenciesHelper.mockURLSession.mockResponses = [RequestTarget.catalogueItems.url: (data, nil, nil)]
        UIApplication.shared.keyWindow?.rootViewController = sut
        sut.beginAppearanceTransition(true, animated: false)
        sut.endAppearanceTransition()
    }
}

// MARK - Tests

extension CatalogueViewControllerTests {

    func test_setViewModel_AssignsDelegate() {
        XCTAssertTrue(sut.viewModel.delegate === sut)
    }

    func test_viewLoad_FetchesCatalogueItems() {
        loadViewOnSUT()
        XCTAssertEqual(sut.collectionView(sut.collectionView, numberOfItemsInSection: 0), 2)
    }

    func test_viewLoad_SetsUpViews() {
        loadViewOnSUT()
        XCTAssertTrue(sut.collectionView.dataSource === sut)
        XCTAssertTrue(sut.collectionView.delegate === sut)
        XCTAssertEqual(sut.collectionView.refreshControl, sut.refreshControl)
    }

    func test_viewLoad_RefreshCollectionView_CellSize() {
        loadViewOnSUT()
        let cell = sut.collectionView(sut.collectionView, cellForItemAt: IndexPath(row: 0, section: 0))
        let screenSize = UIApplication.shared.keyWindow!.bounds.size
        let cellWidth = (screenSize.width / 2) - ((16 * 3) / 2) - 1
        XCTAssertEqual(cell.bounds.size, CGSize(width: cellWidth, height: cellWidth * 1.5))
    }

    func test_senderDidReceive_Loading_AnimatesActivityIndicator() {
        loadViewOnSUT()
        sut.sender(didReceive: CatalogueViewModel.Action.loading)
        XCTAssertTrue(sut.activityIndicator.isAnimating)
    }

    func test_senderDidReceive_CatalogueLoaded_StopsActivityIndicator_StopsrefreshControl() {
        loadViewOnSUT()
        sut.activityIndicator.startAnimating()
        sut.refreshControl.beginRefreshing()
        sut.sender(didReceive: CatalogueViewModel.Action.catalogueLoaded)
        XCTAssertFalse(sut.activityIndicator.isAnimating)
        XCTAssertFalse(sut.refreshControl.isRefreshing)
    }

    func test_senderDidReceive_Failed_StopsActivityIndicator_StopsrefreshControl() {
        loadViewOnSUT()
        sut.activityIndicator.startAnimating()
        sut.refreshControl.beginRefreshing()
        sut.sender(didReceive: CatalogueViewModel.Action.failed("message"))
        XCTAssertFalse(sut.activityIndicator.isAnimating)
        XCTAssertFalse(sut.refreshControl.isRefreshing)
    }

    func test_senderDidReceive_favorite_InformsViewController() {
        loadViewOnSUT()
        sut.sender(didReceive: CatalogueCollectionViewCell.Action.favorite(1161795, true))
        XCTAssertEqual(mockDataStorage.object(forKey: .favorites) as? [Int], [1161795])
    }
}
