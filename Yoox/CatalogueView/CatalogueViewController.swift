//
//  VCatalogueViewController.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import UIKit

final class CatalogueViewController: UIViewController, ViewType {

    struct Constants {
        static let cellSpacing: CGFloat = 16
        static let numberOfColumns = 2
        static let heightRatio: CGFloat = 1.5
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!



    let refreshControl = UIRefreshControl()

    var viewModel: CatalogueViewModel! {
        didSet {
            viewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}

private extension CatalogueViewController {

    func setupViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerNib(withClass: CatalogueCollectionViewCell.self)
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        title = "Catalogue".localized
        refresh()
    }

    @objc func refresh() {
        viewModel.fetchCatalogueItems()
    }
}

extension CatalogueViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.catalogueItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = viewModel.catalogueItems[indexPath.row].catalogueCellModel
        let isFavorite = viewModel.itemIsFavorite(id: model.id)
        return collectionView.dequeueReusableCell(withClass: CatalogueCollectionViewCell.self, for: indexPath) { [weak self] cell in
            cell.delegate = self
            self?.viewModel.fetchImage(forItemID: model.id) { image in
                cell.configure(withImage: image)
            }
            cell.configure(withModel: model, favorite: isFavorite)
        }
    }
}

extension CatalogueViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns = CGFloat(Constants.numberOfColumns)
        let columnWidth = collectionView.frame.width / numberOfColumns
        let cellWidth = columnWidth - ((Constants.cellSpacing * (numberOfColumns + 1)) / numberOfColumns) - 1
        return CGSize(width: cellWidth, height: cellWidth * Constants.heightRatio)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.cellSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insetDimension = Constants.cellSpacing
        return UIEdgeInsets(top: insetDimension,
                            left: insetDimension,
                            bottom: insetDimension,
                            right: insetDimension)
    }
}

extension CatalogueViewController: ActionDelegate {

    func sender(didReceive action: DelegateAction) {
        switch action {
        case CatalogueViewModel.Action.loading:
            activityIndicator.startAnimating()
        case CatalogueViewModel.Action.catalogueLoaded:
            activityIndicator.stopAnimating()
            collectionView.reloadData()
            refreshControl.endRefreshing()
        case CatalogueViewModel.Action.failed(let message):
            // show error message to user here
            print(message)
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        case CatalogueCollectionViewCell.Action.favorite(let id, let isFavorite):
            viewModel.set(itemWithID: id, favorite: isFavorite)
        default:
            break
        }
    }
}
