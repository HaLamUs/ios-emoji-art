//
//  EmojiArtModel.swift
//  LHEmojiArt
//
//  Created by lamha on 28/09/2022.
//

import Foundation

struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    
    // Indentifiable for array
    // Hasable for the set 
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        var id: Int // we dont want anyone can chage id or create BUT we want them can change the (x, y, size)
        // so fileprivate the init
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
        
    }
    
    init() {} // why because we dont want them to create the struct with default value
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
}
