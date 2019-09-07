//
//  MockDispatcher.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation
@testable import Yoox

final class MockDispatcher: Dispatching {

    func background(work: @escaping () -> Void) {
        work()
    }

    func main(work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
}
