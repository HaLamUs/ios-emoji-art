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
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .position(convertFromEmojiCoordinates((0, 0), in: geometry))
                )
    //            ForEach(document.emojis) // dont need \.self cause we implement this Indentiable
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(2)
                } else {
                    ForEach(document.emojis) {
                        emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) {
                providers, location in
//                return true
                return drop(providers: providers, at: location, in: geometry)
            }
        }
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) {
            url in
            document.setBackground(EmojiArtModel.Background.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) {
                image in
                if let data = image.jpegData(compressionQuality: 0.1) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) {
                string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(String(emoji),
                                      at: convertToEmojiCoordinates(location, in: geometry),
                                      size: defaultEmojiFontSize)
                }
            }
        }
        return found
    }
    
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: location.x - center.x,
            y: location.y - center.y
        )
        return (Int(location.x), Int(location.y))
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
                        .onDrag{ NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}
