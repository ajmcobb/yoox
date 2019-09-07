//
//  CatalogueCollectionViewCell.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import UIKit

struct CatalogueCellModel {
    let id: Int
    let title: String
    let price: String?
}

final class CatalogueCollectionViewCell: UICollectionViewCell {

    struct Constants {
        static let favoriteIndicatorColor: UIColor = .darkGray
        static let favoriteIndicatorBorderWidth: CGFloat = 1
    }

    enum Action: DelegateAction {
        case favorite(Int, Bool)
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoriteIndicator: UIView!

    private (set) var id: Int!
    private (set) var isFavorite: Bool = false {
        didSet {
            favoriteIndicator.backgroundColor = isFavorite ? Constants.favoriteIndicatorColor : .clear
        }
    }

    weak var delegate: ActionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteIndicator.layer.cornerRadius = favoriteIndicator.bounds.width / 2
        favoriteIndicator.layer.borderColor = Constants.favoriteIndicatorColor.cgColor
        favoriteIndicator.layer.borderWidth = Constants.favoriteIndicatorBorderWidth
    }

    func configure(withModel model: CatalogueCellModel, favorite: Bool) {
        titleLabel.text = model.title
        priceLabel.text = model.price
        id = model.id
        self.isFavorite = favorite
    }

    func configure(withImage image: UIImage?) {
        imageView.image = image
    }

    @IBAction func toggleFavorite(_ sender: Any) {
        isFavorite = !isFavorite
        delegate?.sender(didReceive: Action.favorite(id, isFavorite))
    }
}
