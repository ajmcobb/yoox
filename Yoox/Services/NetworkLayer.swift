//
//  CatalogueService.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import UIKit

enum NetworkError: Error {
    case offline
    case parsing(Error)
    case urlFailure
    case statusCode(Int)
    case session(Error)
    case data
    case unknown
}

enum RequestMethod {
    case post, get
}

enum RequestScheme: String {
    case http
    case https
}

protocol Target {
    var scheme: RequestScheme { get }
    var baseURL: String { get }
    var method: RequestMethod { get }
    var path: String { get }
    var query: [String: String] { get }
    var keyPath: String { get }
}

enum RequestTarget: Target {

    case catalogueItems

    var scheme: RequestScheme {
        switch self {
        case .catalogueItems:
            return .https
        }
    }

    var baseURL: String {
        switch self {
        case .catalogueItems:
            return "api.net-a-porter.com"
        }
    }

    var method: RequestMethod {
        switch self {
        case .catalogueItems:
            return .get
        }
    }

    var path: String {
        switch self {
        case .catalogueItems:
            return "/NAP/GB/en/60/0/summaries"
        }
    }

    var query: [String : String] {
        switch self {
        case .catalogueItems:
            return ["categoryIds": "2"]
        }
    }

    var keyPath: String {
        switch self {
        case .catalogueItems:
            return "summaries"
        }
    }
}

extension RequestTarget {
    var url: URL? {
        var components = URLComponents()
        switch self {
        case .catalogueItems:
            components.scheme = scheme.rawValue
            components.host = baseURL
            components.path = path
            var queries: [URLQueryItem] = []
            query.forEach { queries.append(URLQueryItem(name: $0, value: $1)) }
            components.queryItems = queries
            return components.url
        }
    }
}


final class NetworkLayer {

    let session: URLSession
    private var dataTask: URLSessionDataTask?

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }

    func request<T>(type: T.Type,
                    target: RequestTarget,
                    completion: @escaping (Result<T, NetworkError>) -> Void) where T: Decodable {
        if let url = target.url {
            switch target.method {
                case .get:
                    getRequest(url: url, jsonKeyPath: target.keyPath, completion: completion)
                case .post:
                    break
            }
        } else {
            completion(.failure(.urlFailure))
        }
    }

    func requestImage(url: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let url = URL(string: url) else { completion(.failure(.urlFailure)); return }
        getRequest(url: url) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(.data))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension NetworkLayer {

    func getRequest(url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        dataTask = session.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.dataTask = nil }
            if let error = error {
                if let response = response as? HTTPURLResponse {
                    completion(.failure(.statusCode(response.statusCode)))
                    return
                } else {
                    completion(.failure(.session(error)))
                }
            }
            if let data = data {
                completion(.success(data))
            }
        }
        dataTask?.resume()
    }

    func getRequest<T>(url: URL, jsonKeyPath: String = "", completion: @escaping (Result<T, NetworkError>) -> Void) where T: Decodable {
        getRequest(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded: T = try data.jsonDecode(keyPath: jsonKeyPath)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.parsing(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

enum CodingError: Error {
    case decoding
    case encoding
}

struct CodableUIImage: Codable {

    let image: UIImage

    enum CodinKeys: String, CodingKey {
        case image
    }

    init(image: UIImage) {
        self.image = image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodinKeys.self)
        let imageData = try container.decode(Data.self, forKey: .image)
        guard let image = UIImage(data: imageData) else {
            throw CodingError.decoding
        }
        self.init(image: image)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodinKeys.self)
        guard let data = image.pngData() else {
            throw CodingError.encoding
        }
        try container.encode(data, forKey: .image)
    }
}
