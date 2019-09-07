//
//  StringExtensions.swift
//  Yoox
//
//  Created by Aurelien Cobb on 06/09/2019.
//  Copyright © 2019 Aurelien Cobb. All rights reserved.
//

import Foundation

extension String {

    func substituting(with substitutions: [(String, String)]) -> String {
        var substitutedString = self
        substitutions.forEach { substitutedString = substitutedString.replacingOccurrences(of: $0.0, with: $0.1) }
        return substitutedString
    }
}


extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    func localized(_ arguments: CVarArg...) -> String {
        return withVaList(arguments) { .vaListHandler(self.localized, $0, nil) }
    }

    // http://basememara.com/swifty-localization-xcode-support/
    private static var vaListHandler: (_ key: String, _ arguments: CVaListPointer, _ locale: Locale?) -> String {
        return { return NSString(format: $0, locale: $2, arguments: $1) as String }
    }
}

