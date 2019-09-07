//
//  Storage.swift
//  Yoox
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

enum StorageKey: Hashable {
    case images(String)
    case favorites

    var value: String {
        switch self {
        case .favorites:
            return "favorites"
        case .images(let imageKey):
            return "images" + imageKey
        }
    }
}

protocol Storage {
    func object(forKey key: StorageKey) -> Any?
    func set(_ value: Any?, forKey key: StorageKey)
}

extension UserDefaults: Storage {

    func object(forKey key: StorageKey) -> Any? {
        return object(forKey: key.value)
    }

    func set(_ value: Any?, forKey key: StorageKey) {
        set(value, forKey: key.value)
    }
}

extension FileManager: Storage {

    var applicationDocumentsDirectory: URL? {
        return urls(for: .documentDirectory, in: .userDomainMask).last
    }

    func object(forKey key: StorageKey) -> Any? {
        guard let fileURL = applicationDocumentsDirectory?.appendingPathComponent(key.value) else { return nil }
        return try? Data(contentsOf: fileURL)
    }

    func set(_ value: Any?, forKey key: StorageKey) {
        guard let value = value as? Data,
            let fileURL = applicationDocumentsDirectory?.appendingPathComponent(key.value) else { return }
        try? value.write(to: fileURL)
    }
}
