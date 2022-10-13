//
//  LHEmojiArtApp.swift
//  LHEmojiArt
//
//  Created by lamha on 28/09/2022.
//

import SwiftUI

@main
struct LHEmojiArtApp: App {
    let document = EmojiArtDocument()
    let paletteStore = PaletteStore(name: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
