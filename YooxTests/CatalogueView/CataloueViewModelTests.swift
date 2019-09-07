//
//  CataloueViewModelTests.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import XCTest
@testable import Yoox

// MARK: - Setup

class CataloueViewModelTests: XCTestCase {

    var sut: CatalogueViewModel!
    var dependenciesHelper: DependenciesHelper!
    var mockDelegate: MockActionDelegate!
    var mockDispatcher: MockDispatcher!
    var mockImageStorage: MockStorage!
    var mockDataStorage: MockStorage!

    override func setUp() {
        super.setUp()
        mockDelegate = MockActionDelegate()
        dependenciesHelper = DependenciesHelper()
        mockDispatcher = MockDispatcher()
        mockImageStorage = MockStorage()
        mockDataStorage = MockStorage()
        sut = CatalogueViewModel(dependencies: dependenciesHelper.dependencies,
                                 dispatching: mockDispatcher,
                                 fileStorage: mockImageStorage,
                                 dataStorage: mockDataStorage)
        sut.delegate = mockDelegate
    }

    override func tearDown() {
        sut = nil
        dependenciesHelper = nil
        mockDelegate = nil
        mockDispatcher = nil
        mockImageStorage = nil
        mockDataStorage = nil
        super.tearDown()
    }

    func fetchCatalogueItemsfromTestJSON() {
        let data = try! JSONDecoder().read(fromJSON: "validCatalogueItems", keyPath: "", bundle: .testBundle)
        dependenciesHelper.mockURLSession.mockResponses = [RequestTarget.catalogueItems.url: (data, nil, nil)]
        sut.fetchCatalogueItems()
    }
}

// MARK: - Tests

extension CataloueViewModelTests {

    func test_fetchCatalogueItems_OnSuccess_CachesCatalogueItems_InformsDelegate() {
        fetchCatalogueItemsfromTestJSON()
        XCTAssertEqual(sut.catalogueItems.map { $0.id }, [1161795, 1176874])
        XCTAssertEqual(mockDelegate.received(last: 2), [CatalogueViewModel.Action.loading,
                                                        CatalogueViewModel.Action.catalogueLoaded])
    }

    func test_fetchCatalogueItems_OnFailure_InformsDelegateWithMessage() {
        let url = RequestTarget.catalogueItems.url!
        dependenciesHelper.mockURLSession.mockResponses = [url: (nil, HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil), NetworkError.unknown)]
        
        sut.fetchCatalogueItems()
        XCTAssertEqual(mockDelegate.received(last: 2), [CatalogueViewModel.Action.loading,
                                                        CatalogueViewModel.Action.failed("StatusCode_Error".localized(404))])
    }

    func test_fetchImage_OnSuccess_CompletesWithImage_Persists() {
        fetchCatalogueItemsfromTestJSON()
        let id = 1161795
        let imageURL = URL(string: "https://cache.net-a-porter.com/images/products/1161795/1161795_in_dl.jpg")
        dependenciesHelper.mockURLSession.mockResponses[imageURL] = (UIImage(named: "tickbox")!.pngData(), nil, nil)
        var fetchedImage: UIImage?

        sut.fetchImage(forItemID: id) { image in
            fetchedImage = image
        }

        XCTAssertNotNil(fetchedImage)
        XCTAssertEqual(sut.imageCache.object(forKey: NSNumber(value: id)), fetchedImage)
        XCTAssertEqual(mockImageStorage.object(forKey: .images(String(id))) as! Data, fetchedImage?.pngData())
    }

    func test_fetchImage_OnSuccess_ImageCached_CompletesWithImageWithoutNetworkRequest() {
        fetchCatalogueItemsfromTestJSON()
        let id = 1161795
        let imageURL = URL(string: "https://cache.net-a-porter.com/images/products/1161795/1161795_in_dl.jpg")
        dependenciesHelper.mockURLSession.mockResponses[imageURL] = (UIImage(named: "tickbox")!.pngData(), nil, nil)
        var fetchedImage: UIImage?

        sut.fetchImage(forItemID: id) { image in
            fetchedImage = image
        }

        dependenciesHelper.mockURLSession.mockResponses = [:]
        sut.fetchImage(forItemID: id) { image in
            fetchedImage = image
        }

        XCTAssertNotNil(fetchedImage)
    }

    func test_fetchImage_onError_InformsDelegateWithError() {
        fetchCatalogueItemsfromTestJSON()
        let imageURL = URL(string: "https://cache.net-a-porter.com/images/products/1161795/1161795_in_dl.jpg")
        dependenciesHelper.mockURLSession.mockResponses = [imageURL: (nil, nil, NetworkError.data)]
        sut.fetchImage(forItemID: 1161795) { _ in }
        XCTAssertEqual(mockDelegate.received(last: 1), [CatalogueViewModel.Action.failed("Something_Went_Wrong".localized)])
    }


    func test_fetchImage_ImageIsPersisted_DoesntFetchFromNetwork_CachesImage() {
        fetchCatalogueItemsfromTestJSON()
        let id = 1161795
        dependenciesHelper.mockURLSession.dataTaskInvoked = false
        let image = UIImage(named: "tickbox")!
        mockImageStorage.set(image.pngData(), forKey: .images(String(id)))
        var fetchedImage: UIImage?
        sut.fetchImage(forItemID: id) { image in
            fetchedImage = image
        }

        XCTAssertNotNil(fetchedImage)
        XCTAssertFalse(dependenciesHelper.mockURLSession.dataTaskInvoked)
        XCTAssertEqual(sut.imageCache.object(forKey: NSNumber(value: 1161795)), fetchedImage)
    }

    func test_catalogueCellModel_FirstItem_HasCorrectData() {
        fetchCatalogueItemsfromTestJSON()
        XCTAssertEqual(sut.catalogueItems[0].catalogueCellModel.title, "Rives oversized knitted cardigan ")
        XCTAssertEqual(sut.catalogueItems[0].catalogueCellModel.price, "£400.00")
    }

    func test_setItemWithID_AddFavorite_SetsIntoDataStorage() {
        sut.set(itemWithID: 1, favorite: true)
        XCTAssertEqual(mockDataStorage.object(forKey: .favorites) as? Array<Int>, [1])
    }

    func test_setItemWithID_RemoveFavorite_RemovesFromDataStorage() {

        sut.set(itemWithID: 1, favorite: true)
        sut.set(itemWithID: 2, favorite: true)

        sut.set(itemWithID: 1, favorite: false)
        XCTAssertEqual(mockDataStorage.object(forKey: .favorites) as? Array<Int>, [2])
    }
}

extension CatalogueViewModel.Action: Equatable {
    public static func == (lhs: CatalogueViewModel.Action, rhs: CatalogueViewModel.Action) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.catalogueLoaded, .catalogueLoaded):
            return true
        case (.failed(let left), .failed(let right)) where left == right:
            return true
        default:
            return false
        }
    }
}
