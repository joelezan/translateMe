//  translateView.swift
//  translateMe
//
//  Created by Joel Ezan on 10/27/24.
//

import SwiftUI
import FirebaseFirestore

struct TranslateView: View {
    
    @State private var text: String = ""
    @State private var translatedText: String = ""
    
    // Initialize Firestore
    private var db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Translate Me")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                Spacer()
                
                TextField("Enter your text", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await translateText()
                    }
                }) {
                    Text("Translate Me")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Text(translatedText)
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                            .overlay(
                                VStack {
                                    Rectangle().fill(Color.blue).frame(height: 2)
                                    Spacer()
                                    Rectangle().fill(Color.blue).frame(height: 2)
                                }
                            )
                    )
                    .padding(.horizontal)
                
                NavigationLink(destination: TranslationsView()) {
                    Text("View Saved Transactions")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    func translateText() async {
        guard !text.isEmpty else { return }
        let urlString = "https://api.mymemory.translated.net/get?q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&langpair=en|es"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = jsonResponse["responseData"] as? [String: Any],
               let translatedText = responseData["translatedText"] as? String {
                self.translatedText = decodeHTML(translatedText)
                print("Translated text: \(self.translatedText)")
                await saveTranslation(original: text, translated: self.translatedText)
            }
        } catch {
            print("Translation failed: \(error)")
        }
    }

    func decodeHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return attributedString?.string ?? html
    }
    
    func saveTranslation(original: String, translated: String) async {
        let translationData: [String: Any] = [
            "originalText": original,
            "translatedText": translated,
            "timestamp": Timestamp(date: Date())
        ]
        
        do {
            _ = try await db.collection("translations").addDocument(data: translationData)
            print("Translation saved successfully.")
        } catch {
            print("Error saving translation: \(error)")
        }
    }
}

#Preview {
    TranslateView()
}
