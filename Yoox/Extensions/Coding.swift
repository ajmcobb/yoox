//
//  Coding.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

enum FileError: Error {
    case fileNotFound
}


enum FileExtension: String {
    case json
}

extension Encodable {

    func jsonEncoded() throws -> Data? {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}

extension Data {

    func jsonDecode<T>(keyPath: String = "") throws -> T where T: Decodable  {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: self, keyPath: keyPath)
    }
}

extension JSONDecoder {

    func read(fromJSON fileName: String,
              keyPath: String = "",
              bundle: Bundle = Bundle.main) throws -> Data {
        let filePath = try path(for: fileName, from: bundle)
        return try Data(contentsOf: filePath, options: .dataReadingMapped)
    }

    func read<T>(fromJSON fileName: String,
                 keyPath: String = "",
                 to type: T.Type,
                 bundle: Bundle = Bundle.main) throws -> T where T: Decodable {
        let jsonData = try read(fromJSON: fileName, keyPath: keyPath, bundle: bundle)
        return try decode(T.self, from: jsonData, keyPath: keyPath)
    }

    func decode<T>(_ type: T.Type, from data: Data, keyPath: String) throws -> T where T: Decodable {
        guard keyPath.count > 0 else { return try decode(type, from: data) }
        let toplevel = try JSONSerialization.jsonObject(with: data)
        if let nestedJson = (toplevel as AnyObject).value(forKeyPath: keyPath) {
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson)
            return try decode(type, from: nestedJsonData)
        } else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Nested json not found for key path \"\(keyPath)\""))
        }
    }
}

private extension JSONDecoder {

    func path(for fileName: String, from bundle: Bundle) throws -> URL {
        guard let path = bundle.path(forResource: fileName, ofType: FileExtension.json.rawValue) else { throw FileError.fileNotFound }
        return URL(fileURLWithPath: path)
    }
}
