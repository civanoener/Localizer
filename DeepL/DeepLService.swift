//
//  DeepLService.swift
//  Localizer
//
//  Created by René Schanzenbächer on 25.07.23.
//

import Foundation
import Collections

class DeepLService: ObservableObject{
    
    let availableLocales: [String: String] = [
        "BG": "Bulgarian",
        "CS": "Czech",
        "DA": "Danish",
        "DE": "German",
        "EL": "Greek",
        "EN": "English",
        "ES": "Spanish",
        "ET": "Estonian",
        "FI": "Finnish",
        "FR": "French",
        "HU": "Hungarian",
        "ID": "Indonesian",
        "IT": "Italian",
        "JA": "Japanese",
        "KO": "Korean",
        "LT": "Lithuanian",
        "LV": "Latvian",
        "NB": "Norwegian (Bokmål)",
        "NL": "Dutch",
        "PL": "Polish",
        "PT": "Portuguese (all Portuguese varieties mixed)",
        "RO": "Romanian",
        "RU": "Russian",
        "SK": "Slovak",
        "SL": "Slovenian",
        "SV": "Swedish",
        "TR": "Turkish",
        "UK": "Ukrainian",
        "ZH": "Chinese"]
    let formalities = ["default", "prefer_more", "prefer_less"]
    let authKey = "insert your deepl auth key here"
    
    func translate(value: String, sourceLanguage: String, targetLanguage: String, formalityIndex: Int) async -> String {
        let dictionaries = createDictionaries(from: value, maxPairs: 50)
        let bigDictionary = createDictionary(dictionaries: dictionaries)
        let sourceTranslationDatas = dictionaries.map { SourceTranslationData(text: $0.values.elements, sourceLang: sourceLanguage, targetLang: targetLanguage, formality: formalities[formalityIndex]) }
        var translations = [String]()
        for sourceTranslationData in sourceTranslationDatas {
            let translationData = await getTranslationData(sourceTranslationData: sourceTranslationData)
            translationData.translations.forEach { translations.append($0.text)}
        }
        return createResult(dictionary: bigDictionary, translations: translations)
    }
    
    private func createDictionaries(from input: String, maxPairs: Int) -> [OrderedDictionary<String, String>] {
        let lines = input.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        
        var allPairs = OrderedDictionary<String, String>()
        lines.forEach { line in
            let pair = line.split(separator: "=", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            if pair.count == 2 {
                let key = pair[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let value = pair[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                allPairs[key] = value
            }
        }
        return splitDictionaryIntoSubdictionaries(dictionary: allPairs, maxPairs: maxPairs)
    }
    
    private func splitDictionaryIntoSubdictionaries(dictionary: OrderedDictionary<String, String>, maxPairs: Int) -> [OrderedDictionary<String, String>] {
        let keys = Array(dictionary.keys)
        
        return stride(from: 0, to: keys.count, by: maxPairs).map { start in
            let end = min(start + maxPairs, keys.count)
            let subKeys = keys[start..<end]
            var subDict = OrderedDictionary<String, String>()
            
            subKeys.forEach { key in
                subDict[key] = dictionary[key]
            }
            
            return subDict
        }
    }
    
    private func createDictionary(dictionaries: [OrderedDictionary<String, String>]) -> OrderedDictionary<String, String>{
        var bigDictionary = OrderedDictionary<String, String>()
        for dictionary in dictionaries {
            for key in dictionary.keys{
                bigDictionary[key] = dictionary[key]!
            }
        }
        return bigDictionary
    }
    
    private func createResult(dictionary: OrderedDictionary<String, String>, translations: [String]) -> String{
        var result = ""
        for index in dictionary.keys.indices{
            result += "\"" + dictionary.keys[index] + "\"" + "=" + "\"" + translations[index] + "\"" + ";\n"
        }
        return result
    }
    
    private func getTranslationData(sourceTranslationData: SourceTranslationData) async -> TranslationData{
        let url = URL(string: "https://api-free.deepl.com/v2/translate")!
        var request = URLRequest(url: url)
        request.setValue("DeepL-Auth-Key \(authKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONEncoder().encode(sourceTranslationData)
        } catch {
            print("Failed to serialize data")
        }
        var translationData = TranslationData(translations: [Translation]())
        do{
            let (data, _) = try await URLSession.shared.data(for: request)
            translationData = try JSONDecoder().decode(TranslationData.self, from: data)
        }catch{
            print(error)
        }
        return translationData
    }
}
