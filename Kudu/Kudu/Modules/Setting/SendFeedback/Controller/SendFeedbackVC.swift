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
	var queryType: FeedbackQueryType?
    var dropDownOpen = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.handleViewActions = { [weak self] in
            guard let strongSelf = self else { return }
            switch $0 {
            case .submitButtonPressed:
                mainThread({
                    strongSelf.validateForm()
                })
            case .backButtonPressed:
                strongSelf.pop()
            }
        }
    }
    
    func validateForm() {
        
        if isUploading {
            baseView.showError(message: LSCollection.Setting.pleasewaitWhileUploading)
            return
        }
        
        if self.name.isEmpty {
            baseView.showError(message: LSCollection.Setting.pleaseEnterYourName)
            return
        }
        if !CommonValidation.isValidName(self.name) {
            baseView.showError(message: LSCollection.Setting.pleaseEnterValidName)
            return
        }
        if self.number.isEmpty {
            baseView.showError(message: LSCollection.Setting.pleaseEnterYourMobileNumber)
            return
        }
        if !CommonValidation.isValidPhoneNumber(self.number) {
            baseView.showError(message: LSCollection.Setting.pleaseEnterValidNumber)
            return
        }
        if self.feedback.isEmpty {
            baseView.showError(message: LSCollection.Setting.pleaseEnterYourFeedback)
            return
        }
        if self.feedback.count < 5 {
            baseView.showError(message: LSCollection.Setting.pleaseEnterValidFeedback)
			return
        }
        let email: String? = self.email.isEmpty ? nil : self.email
        if email.isNotNil {
            if !CommonValidation.isValidEmail(email!) {
                baseView.showError(message: LSCollection.Setting.pleaseEnterValidEmailId)
				return
            }
        }
        let imageLink: String? = self.imageLink.isEmpty ? nil : self.imageLink
		if queryType.isNil {
			baseView.showError(message: "Please select Query Type")
			return
		}
        self.baseView.submitButton.startBtnLoader(color: .white)
        self.baseView.tableView.isUserInteractionEnabled = false
		self.sendFeedback(SendFeedbackRequest(name: self.name, phoneNumber: self.number, email: email, feedback: self.feedback, image: imageLink, queryType: self.queryType!))
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
            let cameraPermissionAlert = CameraPermissionDeniedView(frame: CGRect(x: 0, y: 0, width: CameraPermissionDeniedView.popUpWidth, height: CameraPermissionDeniedView.popUpHeight))
            cameraPermissionAlert.configure(type: .noCamera, leftButtonTitle: LSCollection.Home.cancel, rightButtonTitle: LSCollection.Home.setting, container: self.baseView)
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
            let cameraPermissionAlert = CameraPermissionDeniedView(frame: CGRect(x: 0, y: 0, width: CameraPermissionDeniedView.popUpWidth, height: CameraPermissionDeniedView.popUpHeight))
            cameraPermissionAlert.configure(type: .noGallery, leftButtonTitle: LSCollection.Setting.cancel, rightButtonTitle: LSCollection.Setting.settings, container: self.baseView)
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
		case .queryType:
			let cell = tableView.dequeueCell(with: FeebackQueryTypeCell.self)
			cell.configure(queryTypeSelected: self.queryType, queryDropDownOpen: self.dropDownOpen)
			cell.queryTypeSelected = { [weak self] (queryType, dropDownState) in
				let index = SendFeedbackView.Cells.queryType.rawValue
				mainThread {
					self?.queryType = queryType
					self?.dropDownOpen = dropDownState
					self?.baseView.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
				}
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
			cell.showAlert = { [weak self] in
				mainThread {
					self?.openAlert()
				}
			}
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
		let index = SendFeedbackView.Cells.queryType.rawValue
		self.dropDownOpen = false
		self.baseView.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
		
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
        APIEndPoints.SettingsEndPoints.sendFeedback(request: req, success: { [weak self] in
            debugPrint($0.message ?? "")
            self?.baseView.submitButton.stopBtnLoader()
            self?.baseView.showSuccessPopUp(completion: { [weak self] in
                self?.pop()
            })
        }, failure: { [weak self] in
            debugPrint($0.msg)
            self?.baseView.submitButton.stopBtnLoader()
            self?.baseView.tableView.isUserInteractionEnabled = true
            self?.baseView.showError(message: $0.msg)
        })
    }
}

extension SendFeedbackVC {
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		let index = SendFeedbackView.Cells.queryType.rawValue
		self.dropDownOpen = false
		self.baseView.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
	}
}
