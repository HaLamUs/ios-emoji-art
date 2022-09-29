//
//  EmojiArtModel.Background.swift
//  LHEmojiArt
//
//  Created by lamha on 29/09/2022.
//

import Foundation

extension EmojiArtModel {
    
    enum Background {
        case blank
        case url(URL) // this called assiciated data
        case imageData(Data)
        
        // syntatic sugar for someone else using which not need to switch case
        var url: URL? {
            switch self {
            case .url(let url):
                return url
            default: return nil
            }
        }
        
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
        
        
        
    }
    
}
