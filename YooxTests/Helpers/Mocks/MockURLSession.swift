//
//  MockURLSession.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

@testable import Yoox

typealias Response = (Data?, URLResponse?, Error?)

struct MockURLSessionResponse {

    let data: Data?
    let urlResponse: URLResponse?
    let error: Error?

    init(data: Data? = nil,
         urlResponse: URLResponse? = nil,
         error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error
    }
}

final class MockURLSession: URLSession {

    var mockResponses: [URL?: Response] = [:]
    var dataTaskInvoked = false

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskInvoked = true
        let mockResponse = mockResponses[url] ?? (nil, nil, NetworkError.data)
        return MockURLSessionDataTask(mockResponse: mockResponse, completion: completionHandler)
    }
}

final class MockURLSessionDataTask: URLSessionDataTask {

    let mockResponse: Response
    let completion: (Response) -> Void
    init(mockResponse: Response, completion: @escaping (Response) -> Void) {
        self.mockResponse = mockResponse
        self.completion = completion
    }

    override func resume() {
        completion(mockResponse)
    }
}
