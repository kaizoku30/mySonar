//
//  UpdateVehicleDetailsView.swift
//  Kudu
//
//  Created by Admin on 21/09/22.
//

import UIKit
import DropDown

class UpdateVehicleDetailsView: UIView {
    @IBOutlet var mainContentView: UIView!
    @IBOutlet private weak var bottomSheet: UIView!
    @IBOutlet private weak var actionSheet: UIView!
    @IBOutlet private weak var tapGestureView: UIView!
    // Constraints
    @IBOutlet private weak var bottomPaddingMainView: NSLayoutConstraint! //Need to move with keyboard
    @IBOutlet private weak var updateButton: AppButton!
    
    // Textfields
    @IBOutlet private weak var carBrandNameContainer: UIView!
    @IBOutlet private weak var carPlateNumberTFContainer: UIView!
    @IBOutlet private weak var carPlateNumberTF: AppTextFieldView!
    @IBOutlet private weak var carBrandNameLabel: UILabel!
    
    @IBOutlet private weak var colorsContainer: UIView!
    // Outer Circles Outlet
    @IBOutlet private weak var outerCircle1: UIView!
    @IBOutlet private weak var outerCircle2: UIView!
    @IBOutlet private weak var outerCircle3: UIView!
    @IBOutlet private weak var outerCircle4: UIView!
    @IBOutlet private weak var outerCircle5: UIView!
    
    // Inner Circles Outlet
    @IBOutlet private weak var innerCircle1: UIView!
    @IBOutlet private weak var innerCircle2: UIView!
    @IBOutlet private weak var innerCircle3: UIView!
    @IBOutlet private weak var innerCircle4: UIView!
    @IBOutlet private weak var innerCircle5: UIView!
    
    // Image Padding View Outlets
    @IBOutlet private weak var imagePaddingView1: UIView!
    @IBOutlet private weak var imagePaddingView2: UIView!
    @IBOutlet private weak var imagePaddingView3: UIView!
    @IBOutlet private weak var imagePaddingView4: UIView!
    @IBOutlet private weak var imagePaddingView5: UIView!
    
    // Images
    @IBOutlet private weak var imageView1: UIImageView!
    @IBOutlet private weak var imageView2: UIImageView!
    @IBOutlet private weak var imageView3: UIImageView!
    @IBOutlet private weak var imageView4: UIImageView!
    @IBOutlet private weak var imageView5: UIImageView!
    
    // Color Picker
    @IBOutlet private weak var colorPickerView: UIView!
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        if updateButton.backgroundColor != unselectedButtonBgColor {
            updateButton.startBtnLoader(color: .white)
            self.isUserInteractionEnabled = false
            var colorCode = self.selectedCarColor?.hexString ?? "#FFFFFF"
            colorCode.removeFirst()
            APIEndPoints.CartEndPoints.updateVehicleDetails(updateReq: VehicleUpdateRequest(vehicleName: self.carBrandNameLabel.text ?? "", vehicleNumber: self.carPlateNumberTF.currentText, colorCode: colorCode), success: { _ in
                self.isUserInteractionEnabled = true
                self.vehicleDetailsUpdated?()
                self.removeFromContainer()
            }, failure: { _ in
                self.isUserInteractionEnabled = true
                self.updateButton.stopBtnLoader(titleColor: .white)
            })
        }
    }
    @IBAction func dropDownPressed(_ sender: Any) {
        tappedBrandName()
    }
    
    private var outerCirlces: [UIView] = []
    private var innerCircles: [UIView] = []
    private var imageViews: [UIImageView] = []
    private var imagePaddings: [UIView] = []
    static var ContentHeight: CGFloat { 479 }
    private weak var containerView: UIView?
    private var colors: [UIColor] = [.white, .black, .red, .blue, .brown]
    private var selectedIndex = 0
    private var previouslySelectedIndex = 0
    var presentColorPicker: ((UIViewController) -> Void)?
    var dismissColorPicker: (() -> Void)?
    
    lazy var colorPickerController = UIColorPickerViewController()
    private var unselectedContainerColor: UIColor!
    private var unselectedPlaceholderColor: UIColor!
    private var unselectedButtonBgColor: UIColor!
    private var unselectedButtonTextColor: UIColor!
    private var selectedCarColor: UIColor?
    
    var vehicleDetailsUpdated: (() -> Void)?
    private var brandNames: [String] = ["Suzuki", "Hyundai", "Renault", "Maruti", "Honda", "Toyota"]
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder adecoder: NSCoder) {
        super.init(coder: adecoder)
        commonInit()
    }
    
    private func checkButtonCriteria() {
        if self.carBrandNameLabel.textColor == .black && self.carPlateNumberTF.currentText.isEmpty == false && selectedCarColor.isNotNil {
            self.updateButton.setTitle(prefillExists ? "Update" : "Add", for: .normal)
            self.updateButton.setTitleColor(.white, for: .normal)
            self.updateButton.backgroundColor = AppColors.kuduThemeYellow
        } else {
            self.updateButton.setTitle("Add", for: .normal)
            self.updateButton.setTitleColor(unselectedButtonTextColor, for: .normal)
            self.updateButton.backgroundColor = unselectedButtonBgColor
        }
    }
    
    @objc private func tappedCircle(_ sender: UITapGestureRecognizer) {
        let senderView = sender.view
        let tag = senderView?.tag ?? 0
        let selectedColor = colors[tag]
        selectColor(selectedColor)
    }
    
    @objc private func tappedBrandName() {
        let dropDown = DropDown()
        dropDown.anchorView = carBrandNameContainer
        dropDown.direction = .bottom
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)! + 5)
        dropDown.dataSource = brandNames
        dropDown.selectionAction = { [unowned self] (_, item) in
            self.carBrandNameLabel.textColor = .black
            self.carBrandNameLabel.text = item
            self.activateContainer(self.carBrandNameContainer, activate: true)
            self.checkButtonCriteria()
        }
        dropDown.show()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("UpdateVehicleDetailsView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        actionSheet.roundTopCorners(cornerRadius: 32)
        bottomSheet.transform = CGAffineTransform(translationX: 0, y: UpdateVehicleDetailsView.ContentHeight)
        tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeFromContainer)))
        carBrandNameContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedBrandName)))
        outerCirlces = [outerCircle1, outerCircle2, outerCircle3, outerCircle4, outerCircle5]
        for (index, element) in outerCirlces.enumerated() {
            element.tag = index
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedCircle(_ :)))
            element.addGestureRecognizer(gestureRecognizer)
        }
        innerCircles = [innerCircle1, innerCircle2, innerCircle3, innerCircle4, innerCircle5]
        imageViews = [imageView1, imageView2, imageView3, imageView4, imageView5]
        imagePaddings = [imagePaddingView1, imagePaddingView2, imagePaddingView3, imagePaddingView4, imagePaddingView5]
        if UIDevice.bounds.width < 321 {
            colors.removeLast()
            outerCirlces.removeLast()
            innerCircles.removeLast()
            imageViews.removeLast()
            imagePaddings.removeLast()
        }
        colorPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(colorPickerTapped)))
        carPlateNumberTF.textFieldType = .address
        handleTextField()
        unselectedContainerColor = carBrandNameContainer.backgroundColor
        unselectedPlaceholderColor = carBrandNameLabel.textColor
        unselectedButtonBgColor = updateButton.backgroundColor
        unselectedButtonTextColor = updateButton.titleColor(for: .normal)
        carPlateNumberTF.placeholderText = "Car Plate Number"
        carPlateNumberTF.txtField.autocapitalizationType = .allCharacters
    }
    
    @objc private func colorPickerTapped() {
        colorPickerController.view.backgroundColor = .white
        colorPickerController.supportsAlpha = false
        let navVC = UINavigationController(rootViewController: colorPickerController)
        navVC.view.backgroundColor = .white
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(colorConfirmed))
        doneButton.tintColor = .black
        colorPickerController.navigationController?.navigationBar.tintColor = .black
        colorPickerController.navigationItem.setRightBarButton(doneButton, animated: true)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(colorPickerDismissed))
        cancelButton.tintColor = .black
        colorPickerController.navigationItem.setLeftBarButton(cancelButton, animated: true)
        //colorPickerController.navigationController?.toolbarItems = [doneButton]
        self.presentColorPicker?(navVC)
    }
    
    @objc private func colorConfirmed() {
        self.selectColor(colorPickerController.selectedColor)
        self.dismissColorPicker?()
    }
    
    @objc private func colorPickerDismissed() {
        self.dismissColorPicker?()
    }
    
    @objc private func removeFromContainer() {
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: UpdateVehicleDetailsView.ContentHeight)
        }, completion: { _ in
            self.containerView?.subviews.forEach({
                if $0.tag == Constants.CustomViewTags.alertTag {
                    $0.removeFromSuperview()
                }
            })
            self.containerView?.subviews.forEach({
                if $0.tag == Constants.CustomViewTags.dimViewTag {
                    $0.removeFromSuperview()
                }
            })
        })
    }
    
    private var prefillExists = false
    
    func configure(container view: UIView, prefill: VehicleDetails?) {
        self.containerView = view
        self.setColors()
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        view.addSubview(self)
        if let prefill = prefill, prefill._id ?? "" != "" {
            prefillExists = true
            handlePrefill(vehicle: prefill)
        }
        UIView.animate(withDuration: 1, animations: {
            self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: {
            if $0 {
                //Need to decide if anything needed here
            }
        })
    }
    
    private func handlePrefill(vehicle: VehicleDetails) {
        if brandNames.contains(vehicle.vehicleName ?? "") == false {
            brandNames.append(vehicle.vehicleName ?? "")
        }
        let colorCode = vehicle.colorCode ?? "#FFFFFF"
        let color = colorCode.uiColorFor6CharHex
        self.selectColor(color)
        self.carBrandNameLabel.text = vehicle.vehicleName ?? ""
        self.carBrandNameLabel.textColor = .black
        self.activateContainer(carBrandNameContainer, activate: true)
        self.carPlateNumberTF.currentText = vehicle.vehicleNumber ?? ""
        self.activateContainer(carPlateNumberTFContainer, activate: true)
        self.checkButtonCriteria()
    }
    
}

extension UpdateVehicleDetailsView {
    
    private func setColors() {
        for (index, element) in outerCirlces.enumerated() {
            element.backgroundColor = colors[index]
            if colors[index] == UIColor.white {
                element.borderWidth = 1
                element.borderColor = .black.withAlphaComponent(0.12)
            }
        }
        for (index, element) in innerCircles.enumerated() {
            element.backgroundColor = colors[index]
        }
        for (index, element) in imageViews.enumerated() {
            element.backgroundColor = colors[index]
        }
        for (index, element) in imagePaddings.enumerated() {
            element.backgroundColor = colors[index]
            element.cornerRadius = 15
        }
        for (index, element) in imageViews.enumerated() {
            element.backgroundColor = colors[index]
            element.tintColor = .white
            element.image = nil
        }
    }
    
    private func selectColor(_ color: UIColor) {
        self.selectedCarColor = color
        if let alreadyExists = self.colors.firstIndex(where: { $0 == color }) {
            previouslySelectedIndex = selectedIndex
            selectedIndex = alreadyExists
            setAfterSelection(color)
        } else {
            colors.removeLast()
            colors.insert(color, at: 0)
            setColors()
            previouslySelectedIndex = selectedIndex
            selectedIndex = 0
            setAfterSelection(color)
        }
        self.checkButtonCriteria()
    }
    
    private func setAfterSelection(_ color: UIColor) {
        innerCircles[previouslySelectedIndex].backgroundColor = colors[previouslySelectedIndex]
        imageViews[previouslySelectedIndex].image = nil
        innerCircles[selectedIndex].backgroundColor = .white
        imageViews[selectedIndex].tintColor = color == .white ? .black : .white
        imageViews[selectedIndex].image = AppImages.VehicleDetails.selectedCheck
    }
}

extension UpdateVehicleDetailsView {
    private func handleTextField() {
        carPlateNumberTF.textFieldDidBeginEditing = { [weak self] in
            guard let view = self?.carPlateNumberTFContainer else { return }
            self?.activateContainer(view, activate: self?.carPlateNumberTF.currentText ?? "" != "")
        }
        carPlateNumberTF.textFieldFinishedEditing = { [weak self] _ in
            guard let view = self?.carPlateNumberTFContainer else { return }
            self?.activateContainer(view, activate: self?.carPlateNumberTF.currentText ?? "" != "")
        }
        carPlateNumberTF.textFieldClearBtnPressed = { [weak self] in
            guard let view = self?.carPlateNumberTFContainer else { return }
            self?.activateContainer(view, activate: false)
        }
        carPlateNumberTF.textFieldDidChangeCharacters = { [weak self] in
            guard let view = self?.carPlateNumberTFContainer else { return }
            self?.activateContainer(view, activate: $0 != "")
            self?.checkButtonCriteria()
        }
    }
    
    private func activateContainer(_ view: UIView, activate: Bool) {
        view.backgroundColor = activate ? .white : unselectedContainerColor
        view.borderWidth = activate ? 1 : 0
        view.borderColor = activate ? UIColor.black.withAlphaComponent(0.1) : .clear
    }
}
