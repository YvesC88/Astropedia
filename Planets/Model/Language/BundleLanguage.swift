//
//  BundleLanguage.swift
//  Planets
//
//  Created by Yves Charpentier on 09/06/2023.
//

import Foundation

protocol LanguageProtocol {
    func getCurrentLanguage() -> String
}

class BundleLanguage: LanguageProtocol {
    func getCurrentLanguage() -> String {
        return Bundle.main.preferredLocalizations.first ?? "fr"
    }
}
    
