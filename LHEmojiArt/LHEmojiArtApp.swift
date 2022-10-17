//
//  LHEmojiArtApp.swift
//  LHEmojiArt
//
//  Created by lamha on 28/09/2022.
//

import SwiftUI

@main
struct LHEmojiArtApp: App {
    // @StateObject is single source of truth ??
    @StateObject var document = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(name: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
                .environmentObject(paletteStore) // PaletteChooser is child's of EmojiArt
            // chỉ truyền đc 1 VM theo cách env này 
        }
    }
}
