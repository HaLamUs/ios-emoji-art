//
//  EmojiArtDocument.swift
//  LHEmojiArt
//
//  Created by lamha on 29/09/2022.
//

// this one is ViewModel: ObservableOject
//
import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    // hold a Model
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNeed()
            }
        }
    }
    
    
    private var autosaveTimer: Timer?
    
    private func scheduleAutosave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) {
            timer in
            self.autosave() // no weak cause we want to keep this
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let coalescingInterval = 5.0
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            let printData = String(data: data, encoding: .utf8) ?? "nil"
            print("\(thisFunction) json = \(printData)")
            
            try data.write(to: url)
            
            print("\(thisFunction) success!")
        }
        catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) couldnt endcode EmojiArt as JSON because\(encodingError.localizedDescription)")
        }
        catch {
//            print("EmojiArtDocument.save(to: ) error = \(error)")
            print("\(thisFunction) error = \(error)")
        }
    }
    
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNeed()
        }
        else {
            emojiArt = EmojiArtModel()
    //        emojiArt.addEmoji("🛻", at: (-200, -100), size: 80)
    //        emojiArt.addEmoji("🏎", at: (50, 100), size: 40)
        }
    }
    
    // dont necessary but nice to have
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageDataIfNeed() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch url
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel() // will clean up the current loading image if has
            
            //c2 - Combine
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url) //(1)
                .map {
                    (data, urlResponse) in // cái này là output của publisher (1)
                    UIImage(data: data) // ta transfer nó thàng img đây là publisher (2)
                }
                .replaceError(with: nil) // we dont want to handle err case so
                .receive(on: DispatchQueue.main)
            
            backgroundImageFetchCancellable = publisher
                .sink {
                    [weak self] image in
                    self?.backgroundImage = image
                    self?.backgroundImageFetchStatus = (image != nil) ? .idle: .failed(url)
                }
            
            
//            backgroundImageFetchCancellable = publisher
//                .sink(receiveCompletion: {
//                    result in
//                    switch result {
//                    case .finished:
//                        print("success!")
//                    case .failure(let error):
//                        print("Error: \(error)")
//                    }
//                }, receiveValue: {
//                    [weak self] image in
//                    self?.backgroundImage = image
//                    self?.backgroundImageFetchStatus = (image != nil) ? .idle: .failed(url)
//                })
            
//            backgroundImageFetchCancellable = publisher
//                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
            // dùng assign để gán var, nhưng làm ntn lại ko biết đc trạng thái để tắt fetching
            // use let cancellable = publisher inside this scope will trigger the sink stop right away
            
            /* c1
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    // we check after download user change the image?
             // vì cái này là closure, user có thể đổi ảnh mới trong khi app đang đown ảnh cũ, nên phải so sánh cái url NEW: emojiArt.background
             vs cái url OLD EmojiArtModel.Background.url(url)
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        if let imageData = imageData {
                            self?.backgroundImage = UIImage(data: imageData)
                            self?.backgroundImageFetchStatus = .idle
                        }
                        if self?.backgroundImage == nil {
                            self?.backgroundImageFetchStatus = .failed(url)
                        }
             // WITHOUT weak self, this will keep this closure 4ever in memory
                    }
                }
            }*/
            
            
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

