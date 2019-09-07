//
//  ViewModel.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

protocol ViewModel {
    var dependencies: Dependencies { get }
}

protocol ViewType {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
}
