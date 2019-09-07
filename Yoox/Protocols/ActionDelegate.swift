//
//  ActionDelegate.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

protocol DelegateAction {}

protocol ActionDelegate: class {
    func sender(didReceive action: DelegateAction)
}
