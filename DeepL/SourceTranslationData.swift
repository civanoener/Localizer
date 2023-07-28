//
//  ExportData.swift
//  Localizer
//
//  Created by René Schanzenbächer on 25.07.23.
//

import Foundation

struct SourceTranslationData: Codable {
    let text: [String]
    let sourceLang: String
    let targetLang: String
    let formality: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case sourceLang = "source_lang"
        case targetLang = "target_lang"
        case formality
    }
}
