//
//  ContentView.swift
//  LHEmojiArt
//
//  Created by lamha on 28/09/2022.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    // hold a view model
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        GeometryReader {
            geometry in
            ZStack {
                Color.yellow
    //            ForEach(document.emojis) // dont need \.self cause we implement this Indentiable
                ForEach(document.emojis) {
                    emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }
        }
        
        
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geomery: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geomery)
    }
    
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y)
        )
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    private let testEmojis = "🚕🚌🚜🛵🚙🚎🛻🏎🚗🚘🏍🚆🚡✈️🚁🛺⛵️🚤🛥🛰"
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map {String($0)}, id: \.self) {
                    emoji in
                    Text(emoji)
                }
            }
        }
    }
}
