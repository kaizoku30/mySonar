//
//  SendFeedbackVC.swift
//  Kudu
//
//  Created by Admin on 22/07/22.
//

import UIKit
import AVFoundation
import Photos
import SwiftUI

class SendFeedbackVC: BaseVC {
    @IBOutlet var baseView: SendFeedbackView!
    var isUploaded = false
    var isUploading = false
    
    var imageUploaded: UIImage?
    var percentage: CGFloat = 0
    
    var name: String = ""
    var number: String = ""
    var email: String = ""
    var feedback: String = ""
    var imageLink: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.handleViewActions = { [weak self] in
            guard let `self` = self else { return }
            switch $0 {
            case .submitButtonPressed:
                mainThread({
                    self.validateForm()
                })
            case .backButtonPressed:
                self.pop()
            }
        }
    }
    
    func validateForm() {
        
        if isUploading {
            baseView.showError(message: LocalizedStrings.Setting.pleasewaitWhileUploading)
            return
        }
        
        if self.name.isEmpty {
            baseView.showError(message: LocalizedStrings.Setting.pleaseEnterYourName)
            return
        }
        if !CommonValidation.isValidName(self.name) {
            baseView.showError(message: LocalizedStrings.Setting.pleaseEnterValidName)
            return
        }
        if self.number.isEmpty {
            baseView.showError(message: LocalizedStrings.Setting.pleaseEnterYourMobileNumber)
            return
        }
        if !CommonValidation.isValidPhoneNumber(self.number) {
            baseView.showError(message: LocalizedStrings.Setting.pleaseEnterValidName)
            return
        }
        if self.feedback.isEmpty {
            baseView.showError(message: LocalizedStrings.Setting.pleaseEnterYourFeedback)
            return
        }
        if self.feedback.count < 5 {
            baseView.showError(message: LocalizedStrings.Setting.pleaseEnterValidFeedback)
        }
        let email: String? = self.email.isEmpty ? nil : self.email
        if email.isNotNil {
            if !CommonValidation.isValidEmail(email!) {
                baseView.showError(message: LocalizedStrings.Setting.pleaseEnterValidEmailId)
            }
        }
        let imageLink: String? = self.imageLink.isEmpty ? nil : self.imageLink
        
        self.baseView.submitButton.startBtnLoader(color: .white)
        self.baseView.tableView.isUserInteractionEnabled = false
        self.sendFeedback(SendFeedbackRequest(name: self.name, phoneNumber: self.number, email: email, feedback: self.feedback, image: imageLink))
    }
    
    func openAlert() {
        let mediaPicker = AppMediaPickerView(frame: CGRect(x: 0, y: 0, width: AppMediaPickerView.Width, height: AppMediaPickerView.Height))
        mediaPicker.configure(container: self.baseView)
        mediaPicker.handleAction = { [weak self] in
            switch $0 {
            case .gallery:
                mainThread {
                    self?.openGallery()
                }
            case .camera:
                mainThread {
                    self?.openCamera()
                }
            }
        }
    }
    
    func openCamera() {
        let cameraPermissionAsked = AppUserDefaults.value(forKey: .cameraPermissionAsked) as? Bool ?? false
        if cameraPermissionAsked {
            if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                launchCamera()
            } else {
                showCameraPermissionDenied()
            }
        } else {
            AppUserDefaults.save(value: true, forKey: .cameraPermissionAsked)
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] in
                if $0 {
                    self?.launchCamera()
                } else {
                    self?.showCameraPermissionDenied()
                }
            })
        }
    }
    
    func launchCamera() {
        mainThread {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showCameraPermissionDenied()
            }
        }
    }
    
    func showCameraPermissionDenied() {
        mainThread {
            let cameraPermissionAlert = CameraPermissionDeniedView(frame: CGRect(x: 0, y: 0, width: CameraPermissionDeniedView.Width, height: CameraPermissionDeniedView.Height))
            cameraPermissionAlert.configure(type: .noCamera, leftButtonTitle: "Cancel", rightButtonTitle: "Setting", container: self.baseView)
            cameraPermissionAlert.handleAction = {
                if $0 == .right {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
    }
    
    func openGallery() {
        let galleryAccessRequested = AppUserDefaults.value(forKey: .galleryPermissionAsked) as? Bool ?? false
        if galleryAccessRequested {
            if #available(iOS 14, *) {
                galleryAccessiOS14()
            } else {
                // Fallback on earlier versions
                galleryAccessiOS13()
            }
            
        } else {
            AppUserDefaults.save(value: true, forKey: .galleryPermissionAsked)
            if #available(iOS 14, *) {
                galleryRequestiOS14()
            } else {
                // Fallback on earlier versions
                galleryRequestiOS13()
            }
        }
        
    }
    
    @available(iOS 14, *)
    private func galleryAccessiOS14() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .notDetermined, .denied:
            showGalleryPermissionDenied()
        case .restricted, .authorized, .limited:
            launchGallery()
        @unknown default:
            showGalleryPermissionDenied()
        }
    }
    
    private func galleryAccessiOS13() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined, .denied:
            showGalleryPermissionDenied()
        case .restricted, .authorized, .limited:
            launchGallery()
        @unknown default:
            showGalleryPermissionDenied()
        }
    }
    
    @available(iOS 14, *)
    private func galleryRequestiOS14() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly, handler: { [weak self] in
            switch $0 {
            case .authorized, .limited, .restricted:
                self?.launchGallery()
            case .denied, .notDetermined:
                self?.showGalleryPermissionDenied()
            @unknown default:
                self?.showGalleryPermissionDenied()
            }
        })
    }
    
    private func galleryRequestiOS13() {
        PHPhotoLibrary.requestAuthorization({ [weak self] in
            switch $0 {
            case .authorized, .limited, .restricted:
                self?.launchGallery()
            case .denied, .notDetermined:
                self?.showGalleryPermissionDenied()
            @unknown default:
                self?.showGalleryPermissionDenied()
            }
        })
    }
    
    func launchGallery() {
        mainThread {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                self.showGalleryPermissionDenied()
            }
        }
        
    }
    
    func showGalleryPermissionDenied() {
        mainThread {
            let cameraPermissionAlert = CameraPermissionDeniedView(frame: CGRect(x: 0, y: 0, width: CameraPermissionDeniedView.Width, height: CameraPermissionDeniedView.Height))
            cameraPermissionAlert.configure(type: .noGallery, leftButtonTitle: LocalizedStrings.Setting.cancel, rightButtonTitle: LocalizedStrings.Setting.settings, container: self.baseView)
            cameraPermissionAlert.handleAction = {
                if $0 == .right {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
    }
    
}

extension SendFeedbackVC: UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let allCases = SendFeedbackView.Cells.allCases.count
        return isUploading || isUploaded ? allCases : allCases - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = SendFeedbackView.Cells(rawValue: indexPath.row) else { return UITableViewCell() }
        switch type {
        case .name:
            let cell = tableView.dequeueCell(with: FeedbackNameCell.self)
            cell.configure(name)
            cell.textEntered = { [weak self] in
                self?.name = $0
            }
            return cell
        case .number:
            let cell = tableView.dequeueCell(with: FeedbackNumberCell.self)
            cell.configure(number)
            cell.textEntered = { [weak self] in
                self?.number = $0
            }
            return cell
        case .email:
            let cell = tableView.dequeueCell(with: FeedbackEmailCell.self)
            cell.configure(email)
            cell.textEntered = { [weak self] in
                self?.email = $0
            }
            return cell
        case .textView:
            let cell = tableView.dequeueCell(with: FeedbackTextViewCell.self)
            cell.configure(feedback)
            cell.textEntered = { [weak self] in
                self?.feedback = $0
            }
            return cell
        case .uploadImage:
            let cell = tableView.dequeueCell(with: FeedbackUploadImageCell.self)
            return cell
        case .uploadedImage:
            let cell = tableView.dequeueCell(with: FeedbackUploadedImageCell.self)
            cell.configure(img: self.imageUploaded ?? UIImage(), isUploading: self.isUploading)
            cell.deletePressed = { [weak self] in
                self?.isUploaded = false
                self?.imageLink = ""
                self?.imageUploaded = nil
                self?.isUploading = false
                self?.baseView.tableView.reloadData()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = SendFeedbackView.Cells(rawValue: indexPath.row) else { return }
        switch type {
        case .uploadImage:
                openAlert()
        default:
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
       if let pickedImage = info[.originalImage] as? UIImage {
           self.imageUploaded = pickedImage
           self.isUploading = true
           self.baseView.tableView.reloadData()
           AWSUploadController.uploadTheImageToAWS(compression: 0.7, image: pickedImage, completion: {
               if $1.isNotNil {
                   debugPrint("Error : \( $1?.localizedDescription ?? "")")
               }
               debugPrint("Completed")
               let link = $0 ?? ""
               self.imageLink = link
               self.isUploaded = true
               self.isUploading = false
               self.baseView.tableView.reloadData()
               debugPrint("Aws Link : \(link)")
           }, progress: {
               debugPrint("Progress")
               self.percentage = $0
               debugPrint($0)
           })
       }
       picker.dismiss(animated: true, completion: nil)
   }
}

extension SendFeedbackVC {
    func sendFeedback(_ req: SendFeedbackRequest) {
        WebServices.SettingsEndPoints.sendFeedback(request: req, success: { [weak self] in
            debugPrint($0.message ?? "")
            SKToast.show(withMessage: LocalizedStrings.Setting.feedbackSentSuccessfully)
            self?.pop()
        }, failure: { [weak self] in
            debugPrint($0.msg)
            self?.baseView.submitButton.stopBtnLoader()
            self?.baseView.tableView.isUserInteractionEnabled = true
            self?.baseView.showError(message: $0.msg)
        })
    }
}
