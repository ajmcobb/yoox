//
//  DependenciesHelper.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

@testable import Yoox

final class DependenciesHelper {

    let mockURLSession: MockURLSession

    init(mockURLSession: MockURLSession = MockURLSession()) {
        self.mockURLSession = mockURLSession
    }

    var dependencies: Dependencies {
        return Dependencies(networkLayer: NetworkLayer(session: mockURLSession))
    }
}
