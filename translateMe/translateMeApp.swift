//
//  translateMeApp.swift
//  translateMe
//
//  Created by Joel Ezan on 10/27/24.
//

import SwiftUI
import FirebaseCore

@main
struct translateMeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
        WindowGroup {
            TranslateView()
        }
    }
}
