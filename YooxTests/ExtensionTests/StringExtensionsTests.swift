//
//  StringExtensionsTests.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import XCTest
@testable import Yoox

class StringExtensionsTests: XCTestCase {

    func test_substituting_SubstitutesOccurencesOfStringWithGivenNewString() {
        let originalString = "This is a {{adjective}} {{subject}}"
        XCTAssertEqual(originalString.substituting(with: [("{{adjective}}", "fast"), ("{{subject}}", "car")]), "This is a fast car")
    }
}
