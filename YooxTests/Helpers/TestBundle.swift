//
//  TestBundle.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

import Foundation

final class TestBundleClass {}

extension Bundle {
    static let testBundle = Bundle(for: TestBundleClass.self)
}
