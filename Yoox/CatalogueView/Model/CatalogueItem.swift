//
//  CatalogueItem.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

struct CatalogueItem: Decodable {

    let id: Int
    let name: String
    let price: Price
    let images: Images
}

struct Images: Decodable {

    let shots: [String]
    let sizes: [String]
    let urlTemplate: String
}

struct Price: Decodable {

    let currency: String
    let divisor: Int
    let amount: Int
}
