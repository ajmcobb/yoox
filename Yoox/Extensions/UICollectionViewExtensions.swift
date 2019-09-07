//
//  UICollectionViewExtensions.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

public extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: Reusable {}

extension UICollectionView {

    @discardableResult
    final public func register<T: UICollectionViewCell>(withClass cellClass: T.Type) -> UICollectionView {
        register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        return self
    }

    // TODO: NibLoadable
    @discardableResult
    final public func registerNib<T: UICollectionViewCell>(withClass cellClass: T.Type) -> UICollectionView {
        let nib = UINib(nibName: cellClass.reuseIdentifier, bundle: Bundle(for: cellClass))
        register(nib, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
        return self
    }

    final public func dequeueReusableCell<T>(withClass cellClass: T.Type = T.self, for indexPath: IndexPath, configure: ((T) -> Void)? = nil) -> T where T: UICollectionViewCell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell of type \(cellClass)")
        }
        configure?(cell)
        return cell
    }

}
