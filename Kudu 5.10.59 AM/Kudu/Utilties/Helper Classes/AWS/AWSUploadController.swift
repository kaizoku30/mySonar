import Foundation
import AWSCore
import AWSS3
import UIKit
import AVKit
import AVFoundation

typealias ProgressBlock = (_ progress: Double) -> Void //2
typealias CompletionBlock = (_ response: String?, _ error: Error?) -> Void //3

class AWSUploadController {
    private static let requestParameter = "x-amz-acl"
    private static let publicRead = "public-read"
    
    static func uploadTheVideoToAWS(videoUrl: URL, progress: ProgressBlock?, completion: CompletionBlock?) {
            encodeVideo(videoUrl: videoUrl) { (url) in
                guard let url = url else {
                    let err = NSError(domain: "Error while encoding the video.", code: 01, userInfo: nil)
                    completion?(nil, err)
                    return
                }
                self.uploadVideoToS3(url: url, success: completion, progress: progress)
            }
    }
    
    static func uploadVideoToS3(url: URL, success: CompletionBlock?, progress: ProgressBlock?) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        let transferUtility = AWSS3TransferUtility.default()
        let pathExt = url.pathExtension.lowercased()
        let name = "KUDU_\(UUID().uuidString)." + pathExt
        let progressBlock: AWSS3TransferUtilityProgressBlock = { (_, progres) in
            DispatchQueue.main.async(execute: {
                progress?(progres.fractionCompleted)
            })
        }
        
        expression.progressBlock = progressBlock
        expression.setValue(self.publicRead, forRequestParameter: self.requestParameter)
        expression.setValue(self.publicRead, forRequestHeader: self.requestParameter)
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (_, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    print("Failed with error: \(error)")
                    success?(nil, error)
                } else {
                    let videoUrl = "\(Constants.S3BucketCredentials.s3BaseUrl)\(name)"
                    print(videoUrl)
                    success?(videoUrl, nil)
                }
            })
        }
        do {
            let data = try  Data(contentsOf: url)
            transferUtility.uploadData(
                data,
                bucket: "\(Constants.S3BucketCredentials.s3BucketName)",
                key: "\(name)",
                contentType: "video/mp4",
                expression: expression,
                completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                    if let error = task.error {
                        print("Error: \(error.localizedDescription)")
                        success?(nil, error)
                    }
                    
                    if task.result != nil {
                        // Do something with uploadTask.
                    }
                    return nil
                }
        } catch {
            print("error ", error.localizedDescription)
        }
    }
    
    static func uploadTheImageToAWS(compression: Double = 1, image: UIImage, completion: CompletionBlock?, progress: ProgressBlock?) {
        
        let expression = AWSS3TransferUtilityUploadExpression()
        let transferUtility = AWSS3TransferUtility.default()
        let name = "KUDU_\(UUID().uuidString).jpeg"
        
      // MARK: - Compressing image before making upload request...
        guard let data = image.jpegData(compressionQuality: compression) else {
            let err = NSError(domain: "Error while compressing the image.", code: 01, userInfo: nil)
            completion?(nil, err)
            return
        }
        
        let progressBlock: AWSS3TransferUtilityProgressBlock = { (_, progres) in
            DispatchQueue.main.async(execute: {
                //debugPrint("Image upload progress : \(progres.fractionCompleted)")
                progress?(CGFloat(progres.fractionCompleted))
            })
        }
        
        expression.progressBlock = progressBlock
        expression.setValue(self.publicRead, forRequestParameter: self.requestParameter)
        expression.setValue(self.publicRead, forRequestHeader: self.requestParameter)
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (_, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    printDebug("Failed with error: \(error)")
                    completion?(nil, error)
                } else {
                    let imageURL = "\(Constants.S3BucketCredentials.s3BaseUrl)\(name)"
                    //printDebug(imageURL)
                    completion?(imageURL, nil)
                }
            })
        }
        transferUtility.uploadData(
            data,
            bucket: "\(Constants.S3BucketCredentials.s3BucketName)",
            key: "\(name)",
            contentType: "image/png",
            expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    printDebug("Error: \(error.localizedDescription)")
                    completion?(nil, error)
                }
                
                if task.result != nil {
                    // Do something with uploadTask.
                }
                return nil
        }
    }
    
    static func encodeVideo(videoUrl: URL, resultClosure: @escaping (URL?) -> Void ) {
        
        let copyURL = videoUrl
        let asset = AVURLAsset(url: videoUrl)
        guard let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as NSURL? else {return}
        let fileActualName = copyURL.deletingPathExtension().lastPathComponent
        var fileNameInDocDir = "\(fileActualName).mp4"
        var completePath = docDir.appendingPathComponent(fileNameInDocDir)
        if FileManager.default.fileExists(atPath: completePath?.path ?? "") {
           fileNameInDocDir = "\(fileActualName)_1.mp4"
            completePath = docDir.appendingPathComponent(fileNameInDocDir)
            if FileManager.default.fileExists(atPath: completePath?.path ?? "") {
                guard (try? FileManager.default.removeItem(atPath: completePath?.path ?? "")) != nil else {return}
            }
        }
        
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = completePath
            exportSession.outputFileType = AVFileType.mp4
            let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
            let range = CMTimeRangeMake(start: start, duration: asset.duration)
            exportSession.timeRange = range
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously {
                
                switch exportSession.status {
                case .failed:
                    resultClosure(nil)
                case .cancelled:
                    resultClosure(nil)
                case .completed:
                    resultClosure(completePath)
                default:
                        break
                    }
                }
            } else {
                resultClosure(nil)
            }

    }
    // MARK: Setting S3 server with the credentials...
    /// Set up Amazon s3 (For image uploading) with pool ID
    static func setupAmazonS3(withPoolID poolID: String) {
        
        let credentialsProvider = AWSCognitoCredentialsProvider( regionType: .USEast1,
                                                                 identityPoolId: poolID)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    static func deleteS3Object(fileName: String, handler:@escaping (Bool) -> Void) {
        let s3 = AWSS3.default()
        if let deleteObjectRequest = AWSS3DeleteObjectRequest() {
            deleteObjectRequest.bucket = Constants.S3BucketCredentials.s3BucketName
            deleteObjectRequest.key = fileName
            s3.deleteObject(deleteObjectRequest).continueWith { (task: AWSTask) -> AnyObject? in
                if let error = task.error {
                    print("Error occurred: \(error)")
                    handler(false)
                    return nil
                }
                handler(true)
                print("Deleted successfully.")
                return nil
            }
        } else {
            handler(false)
            print("Something went wrong")
        }
    }
}
