//  translationsView.swift
//  translateMe
//
//  Created by Joel Ezan on 10/28/24.
//

import SwiftUI
import FirebaseFirestore

struct TranslationsView: View {
    
    @State private var translations: [Translation] = []
    private var db = Firestore.firestore()
    
    var body: some View {
        VStack {
            List(translations, id: \.id) { translation in
                Text(translation.translatedText)
            }
            
            Spacer()
            
            Button("Clear All Transactions") {
                clearAllTranslations()
            }
            .frame(width: 300, height: 100)
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
        .onAppear {
            loadTranslations()
        }
    }
    
    func loadTranslations() {
        db.collection("translations").order(by: "timestamp", descending: false).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching translations: \(error)")
            } else {
                self.translations = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Translation.self)
                } ?? []
            }
        }
    }
    
    func clearAllTranslations() {
        let batch = db.batch()
        
        db.collection("translations").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error clearing translations: \(error)")
            } else {
                for document in querySnapshot?.documents ?? [] {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error committing batch delete: \(error)")
                    } else {
                        print("All translations cleared.")
                        self.translations.removeAll() // Clear list in the view
                    }
                }
            }
        }
    }
}

#Preview {
    TranslationsView()
}

// Translation model for Firestore decoding
struct Translation: Identifiable, Decodable {
    @DocumentID var id: String?
    var originalText: String
    var translatedText: String
    var timestamp: Timestamp
}
