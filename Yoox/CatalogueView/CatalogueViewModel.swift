//
//  CatalogueViewModel.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import UIKit

final class CatalogueViewModel: ViewModel {

    struct Constants {
        static let substitutions = [("{{scheme}}", "https:"),
                                    ("{{shot}}", "in"),
                                    ("{{size}}", "dl")]
    }

    enum Action: DelegateAction {
        case loading
        case catalogueLoaded
        case failed(String)
    }

    let dependencies: Dependencies
    let dispatcher: Dispatching
    let fileStorage: Storage
    let dataStorage: Storage

    weak var delegate: ActionDelegate?

    private (set) var catalogueItems: [CatalogueItem] = []
    private (set) var imageCache = NSCache<NSNumber, UIImage>()
    private (set) var favorites: Set<Int> = Set()

    init(dependencies: Dependencies,
         dispatching: Dispatching = Dispatcher(),
         fileStorage: Storage = FileManager(),
         dataStorage: Storage = UserDefaults.standard) {
        self.dependencies = dependencies
        self.dispatcher = dispatching
        self.fileStorage = fileStorage
        self.dataStorage = dataStorage
        self.favorites = Set(dataStorage.object(forKey: .favorites) as? [Int] ?? [])
    }

    func fetchCatalogueItems() {
        delegate?.sender(didReceive: Action.loading)
        dependencies.networkLayer.request(type: [CatalogueItem].self, target: .catalogueItems) { [weak self] result in

            self?.dispatcher.main {
                switch result {
                case .success(let items):
                    self?.catalogueItems = items
                    self?.delegate?.sender(didReceive: Action.catalogueLoaded)
                case .failure(let error):
                    self?.handle(networkError: error)
                }
            }
        }
    }

    func fetchImage(forItemID id: Int, completion: @escaping (UIImage) -> Void) {
        guard let item = item(withID: id) else { return }
        let imageKey = NSNumber(value: id)

        if let image = imageCache.object(forKey: imageKey) {
            completion(image)
        } else if let imageDataFromFile = fileStorage.object(forKey: .images(String(id))) as? Data,
            let image = UIImage(data: imageDataFromFile) {
            imageCache.setObject(image, forKey: imageKey)
            completion(image)
        } else {
            dependencies.networkLayer.requestImage(url: item.images.urlTemplate.substituting(with: Constants.substitutions)) { [weak self] result in
                self?.dispatcher.main {
                    switch result {
                    case .success(let image):
                        self?.imageCache.setObject(image, forKey: imageKey)
                        self?.fileStorage.set(image.pngData(), forKey: .images(String(id)))
                        completion(image)
                    case .failure(let error):
                        self?.handle(networkError: error)
                    }
                }
            }
        }
    }

    func set(itemWithID id: Int, favorite: Bool) {
        if favorite {
            favorites.insert(id)
        } else {
            favorites.remove(id)
        }
        dataStorage.set(Array(favorites), forKey: .favorites)
    }

    func itemIsFavorite(id: Int) -> Bool {
        return favorites.contains(id)
    }
}

private extension CatalogueViewModel {

    func handle(networkError: NetworkError) {
        switch networkError {
        case .offline:
            delegate?.sender(didReceive: Action.failed("Offline_Error".localized))
        case .parsing:
            delegate?.sender(didReceive: Action.failed("Parsing_Error".localized))
        case .urlFailure:
            delegate?.sender(didReceive: Action.failed("WrongURL_Error".localized))
        case .statusCode(let statusCode):
            delegate?.sender(didReceive: Action.failed("StatusCode_Error".localized(statusCode)))
        case .session, .data, .unknown:
            delegate?.sender(didReceive: Action.failed("Something_Went_Wrong".localized))
        }
    }

    func index(forItemWithID id: Int) -> Int? {
        for (index, item) in catalogueItems.enumerated() where item.id == id {
            return index
        }
        return nil
    }

    func item(withID id: Int) -> CatalogueItem? {
        guard let index = index(forItemWithID: id) else { return nil }
        return catalogueItems[index]
    }
}

extension CatalogueItem {

    var catalogueCellModel: CatalogueCellModel {
        return CatalogueCellModel(id: id, title: name, price: price.formatted)
    }
}

extension Price {

    var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.currencyCode = currency
        formatter.numberStyle = .currency
        return formatter

    }

    var formatted: String? {
        let price = NSNumber(value: Float(amount) / Float(divisor))
        return formatter.string(from: price)
    }
}
