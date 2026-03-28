//
//  LanguageManager.swift
//  TodoApp
//
//  Created by Baran on 28.03.2026.
//

import Foundation
import Combine
import SwiftUI

class LanguageManager: ObservableObject {
    @AppStorage("appLanguage") var language: String = "tr" {
        didSet {
            objectWillChange.send()
        }
    }
    
    func localizedString(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

extension String {
    func localized(using manager: LanguageManager) -> String {
        manager.localizedString(self)
    }
}
