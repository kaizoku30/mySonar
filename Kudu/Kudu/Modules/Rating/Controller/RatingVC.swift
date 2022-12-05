//
//  RatingVC.swift
//  Kudu
//
//  Created by Harpreet Kaur on 2022-10-10.
//

import UIKit
import Cosmos

class RatingVC: BaseVC {
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.pop()
    }
    
    @IBAction func btnSubmitTapped(_ sender: UIButton) {
        data.rate = viewRating.rating
        data.description = txtViewComment.text ?? ""
        let response = viewModel.validateData(req: data)
        if !response.validData {
            let errorView = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.view.width - 32, height: 48))
            mainThread {
                errorView.show(message: response.errorMsg ?? "", view: self.view)
            }
        } else {
            btnSubmit.startBtnLoader(color: .white)
        }
    }

    var data: RatingRequestModel = RatingRequestModel()
    let viewModel: RatingViewModel = RatingViewModel()
    
    @IBOutlet weak var imageViewbg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtViewComment: UITextView!
    @IBOutlet weak var btnSubmit: AppButton!
    @IBOutlet weak var viewRating: CosmosView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButton(enabled: false)
        self.intialSetup()
        
    }
    
    //Initial setup
    fileprivate func intialSetup() {
        viewRating.settings.fillMode = .half
        self.addKeyboardObserver()
        viewModel.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        viewRating.didFinishTouchingCosmos = { [weak self] in
            guard let `self` = self else { return }
            self.data.rate = $0
            self.setButton(enabled: self.txtViewComment.text.count > 0 && $0 != 0)
        }
    }
    
    func setOrderId(_ id: String) {
        data.orderId = id
    }
    
    private func setButton(enabled: Bool) {
        btnSubmit.setTitleColor(enabled ? .white : AppColors.unselectedButtonTextColor, for: .normal)
        btnSubmit.backgroundColor = enabled ? AppColors.kuduThemeYellow : AppColors.unselectedButtonBg
    }
}
extension RatingVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let sizeToFitIn = CGSize(width: self.txtViewComment.bounds.size.width, height: CGFloat(MAXFLOAT))
            let newSize = self.txtViewComment.sizeThatFits(sizeToFitIn)
            self.textViewHeight.constant = newSize.height
        self.setButton(enabled: textView.text.count > 0 && data.rate != 0)
    }
}

extension RatingVC: RatingViewModelDelegate {
    func ratingReponseHandling(responseType: Result<Bool, Error>) {
        switch responseType {
        case .success:
            self.pop()
        case .failure(let error):
            let errorView = AppErrorToastView(frame: CGRect(x: 0, y: 0, width: self.view.width - 32, height: 48))
            mainThread {
                errorView.show(message: error.localizedDescription, view: self.view)
            }
        }
    }
}

extension RatingVC {
    //Keybaord Observer for scroll handling.
    fileprivate func addKeyboardObserver() {
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(RatingVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(RatingVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        // move the root view up by the distance of keyboard height
        mainThread({
            let maxYForTextView = self.txtViewComment.frame.maxY
            let keyboardHeight = keyboardSize.height + 34 //Padding
            let keyboardminY = self.view.height - keyboardHeight
            let difference = keyboardminY - maxYForTextView
            if difference > 0 {
                //No scrolling needed
            } else {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: difference), animated: true)
            }
        })
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        //self.scrollView.frame.origin.y = 0
        mainThread({
            self.scrollView.setContentOffset(.zero, animated: true)
        })
    }
}
