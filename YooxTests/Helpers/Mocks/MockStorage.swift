//
//  MockStorage.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

@testable import Yoox

final class MockStorage: Storage {

    var store: [StorageKey: Any] = [:]

    func object(forKey key: StorageKey) -> Any? {
        return store[key]
    }

    func set(_ value: Any?, forKey key: StorageKey) {
        store[key] = value
    }
}
