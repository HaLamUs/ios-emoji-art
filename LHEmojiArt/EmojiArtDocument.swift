//
//  EmojiArtDocument.swift
//  LHEmojiArt
//
//  Created by lamha on 29/09/2022.
//

// this one is ViewModel: ObservableOject
//
import SwiftUI

class EmojiArtDocument: ObservableObject {
    // hold a Model
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNeed()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("🛻", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🏎", at: (50, 100), size: 40)
    }
    
    // dont necessary but nice to have
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
        
    }
    
    private func fetchBackgroundImageDataIfNeed() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch url
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    // we check after download user change the image?
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        if let imageData = imageData {
                            self?.backgroundImage = UIImage(data: imageData)
                            self?.backgroundImageFetchStatus = .idle
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("set bg \(background)")
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat)  {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
}

