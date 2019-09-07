//
//  MockActionDelegate.swift
//  YooxTests
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

@testable import Yoox

final class MockActionDelegate: ActionDelegate {

    private(set) var receivedActions: [DelegateAction] = []

    func sender(didReceive action: DelegateAction) {
        receivedActions.append(action)
    }
    
    func clear() {
        receivedActions = []
    }

    func received<T>(last count: Int) -> [T] where T: DelegateAction {
        return Array(receivedActions.suffix(count)) as? [T] ?? []
    }
}
