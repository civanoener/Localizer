//
//  ExportData.swift
//  Localizer
//
//  Created by René Schanzenbächer on 25.07.23.
//

import Foundation

struct SourceTranslationData: Codable {
    let text: [String]
    let targetLang: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case targetLang = "target_lang"
    }
}
