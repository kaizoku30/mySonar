import Foundation
import UIKit
import AVFoundation

extension URL {

    ///Returns the thumbnail image ( if any ) in the given url
    var thumbnailImage: UIImage? {

        do {
            let asset: AVAsset = AVAsset(url: self)
            let assetImgGenerate: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time: CMTime = CMTimeMakeWithSeconds(2, preferredTimescale: Int32(NSEC_PER_SEC))

            let img: CGImage = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: UIImage = UIImage(cgImage: img)
            return frameImg
        } catch {
        }
        return nil
    }

    ///Can parse the query string and get back a dictionary of the variables.
    var queryItems: [String: String] {
        var params = [String: String]()
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce([:], { (_, item) -> [String: String] in
                params[item.name] = item.value
                return params
            }) ?? [:]
    }

    ///Returns percent encoded url
    var percentEncoded: URL? {

        let urlString = self.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let urlStr = urlString, let url = URL(string: urlStr) {
            return url
        }
        return nil
    }
}
