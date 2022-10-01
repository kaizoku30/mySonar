import Foundation
import AVKit

struct VideoThumbnail {
    
    static var pendingThumbnails: [String] = [] {
        didSet {
            if pendingThumbnails.count == 0 {
                NotificationCenter.postNotificationForObservers(.videoThumbnailsUpdated)
            }
        }
    }
    
    let image: UIImage
    let url: String
    
    static func getThumbnail(url: URL) -> UIImage? {
        let thumbnail = loadImage(videoUrl: url.absoluteString)
        if thumbnail.isNotNil {
            return thumbnail?.image
        } else {
            VideoThumbnail.pendingThumbnails.append(url.absoluteString)
            DispatchQueue.global().async {
                let asset = AVAsset(url: url)
                   let assetImgGenerate = AVAssetImageGenerator(asset: asset)
                   assetImgGenerate.appliesPreferredTrackTransform = true
                   let time = CMTimeMakeWithSeconds(1, preferredTimescale: 60)
                   let times = [NSValue(time: time)]
                   assetImgGenerate.generateCGImagesAsynchronously(forTimes: times, completionHandler: {  _, image, _, _, _ in
                       if let image = image {
                           let uiImage = UIImage(cgImage: image)
                           saveThumbnail(image: uiImage, videoUrl: url.absoluteString)
                           VideoThumbnail.pendingThumbnails.remove(object: url.absoluteString)
                       } else {
                        debugPrint("Could not fetch video thumbnail")
                           VideoThumbnail.pendingThumbnails.remove(object: url.absoluteString)
                       }
                   })
            }
        }
        return nil
    }
    
    private static func saveThumbnail(image: UIImage?, videoUrl: String) {
        if image == nil {
            return }
        guard let data = image?.jpegData(compressionQuality: 0.5) else {
            return }
        let encoded = try? PropertyListEncoder().encode(data)
        if encoded.isNil {
            return }
        UserDefaults.standard.set(encoded!, forKey: videoUrl)
    }

    private static func loadImage(videoUrl: String) -> VideoThumbnail? {
         guard let data = UserDefaults.standard.data(forKey: videoUrl) else { return nil }
         let decoded = try? PropertyListDecoder().decode(Data.self, from: data)
         if decoded.isNil {
             return nil }
         let image = UIImage(data: decoded!)
         return image.isNil ? nil : VideoThumbnail(image: image!, url: videoUrl)
    }
}
