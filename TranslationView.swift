//
//  TranslationView.swift
//  Localizer
//
//  Created by René Schanzenbächer on 25.07.23.
//

import SwiftUI

struct TranslationView: View {
    @State var formalitySelection = ["Default", "Prefer More", "Prefer Less"]
    @State var selectedFormality = "Default"
    @State var sourceText = ""
    @State var targetText = ""
    @State var sourceLocale = "EN"
    @State var targetLocale = "DE"
    @State var isCopyToClipboardActive = false
    
    var availableLocales: [String] {
        return deeplService.availableLocales.keys.map { String($0) }.sorted()
    }
    
    @StateObject var deeplService = DeepLService()
    var body: some View {
        GeometryReader{ geo in
            VStack{
                Spacer()
                HStack{
                    VStack{
                        HStack{
                            Text("Source Language:")
                                .foregroundColor(Color("Secondary"))
                            Spacer()
                            Picker("", selection: $sourceLocale) {
                                ForEach(availableLocales, id: \.self) {
                                    Text("\($0) - \(deeplService.availableLocales[$0]!)")
                                        .foregroundColor(Color("Secondary"))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        TextEditor(text: $sourceText)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(10...500)
                    }
                    Spacer()
                    VStack{
                        HStack{
                            Text("Target Language:")
                                .foregroundColor(Color("Secondary"))
                            Spacer()
                            Picker("", selection: $targetLocale) {
                                ForEach(availableLocales, id: \.self) {
                                    Text("\($0) - \(deeplService.availableLocales[$0]!)")
                                        .foregroundColor(Color("Secondary"))
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        HStack{
                            Text("Formality: ")
                            Spacer()
                            Picker("", selection: $selectedFormality) {
                                ForEach(formalitySelection, id: \.self) {
                                    Text("\($0)")
                                        .foregroundColor(Color("Secondary"))
                                }
                            }
                            .pickerStyle(.radioGroup)
                            .horizontalRadioGroupLayout()
                            .padding(.bottom, 5)
                        }
                        TextEditor(text: .constant(targetText))
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(10...500)
                    }
                }
                .padding(.horizontal)
                .frame(width: geo.size.width)
                HStack{
                    Spacer()
                    if(isCopyToClipboardActive){
                        Button("Copy to Clipboard"){
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(targetText, forType: .string)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Button("Translate"){
                        Task{
                            let formalityIndex = formalitySelection.firstIndex(of: selectedFormality)!
                            targetText = await deeplService.translate(value: sourceText,
                                                                      sourceLanguage: sourceLocale,
                                                                      targetLanguage: targetLocale,
                                                                      formalityIndex: formalityIndex)
                            isCopyToClipboardActive = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("Special"))
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color("Primary"))
        }
        
    }
}

struct TranslationView_Previews: PreviewProvider {
    static var previews: some View {
        TranslationView()
    }
}
