//
//  TranslationData.swift
//  Localizer
//
//  Created by René Schanzenbächer on 25.07.23.
//

import Foundation

struct TranslationData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let detectedSourceLanguage: String
    let text: String
    
    enum CodingKeys: String, CodingKey {
        case detectedSourceLanguage = "detected_source_language"
        case text
    }
}
