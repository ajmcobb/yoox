//
//  Dispatching.swift
//  Yoox
//
//  Created by Aurelien Cobb on 07/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

protocol Dispatching {
    func background(work: @escaping () -> Void)
    func main(work: @escaping () -> Void)
}

final class Dispatcher: Dispatching {

    func background(work: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async(execute: work)
    }

    func main(work: @escaping () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
}
