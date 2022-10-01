//
//  CustomisableItemDetailView.swift
//  Kudu
//
//  Created by Admin on 24/08/22.
//

import UIKit
import NVActivityIndicatorView
import Kingfisher

struct ModifierPriceObject {
    var quantity: Int
    var priceIndv: Double
    var id: String
}

class CustomisableItemDetailView: UIView {
    @IBOutlet weak var safeAreaMinGradientImage: UIImageView!
    @IBOutlet weak var safeAreaGradientImage: UIImageView!
    @IBOutlet weak var cartBannerGradientImage: UIImageView!
    @IBOutlet private weak var addButton: AppButton!
	@IBOutlet private var mainContentView: UIView!
	@IBOutlet private weak var resetButton: AppButton!
	@IBOutlet private weak var dismissButton: AppButton!
	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var bottomSheet: UIView!
	@IBOutlet private weak var topPaddingConstraint: NSLayoutConstraint!
	@IBOutlet private weak var cartView: UIView!
	@IBOutlet private weak var tapGestureView: UIView!
    @IBOutlet private weak var cartLabel: UILabel!
    @IBOutlet private weak var safeAreaPaddingView: UIView!
    
    @IBAction private func resetButtonPressed(_ sender: Any) {
        self.setTemplateConfiguration(preLoadTemplate: nil)
        setCartView(enabled: !requiredModGroupsCriteriaSatisfed.contains(false))
        self.tableView.reloadData()

	}
	
	@IBAction private func dismissButtonPressed(_ sender: Any) {
		self.handleDeallocation?()
		removeFromContainer()
	}
	
	@IBAction private func addToCartPressed(_ sender: Any) {
		
        if cartBannerGradientImage.isHidden == true { return }
		
		let templateChanged = self.template.modGroups?.contains(where: { (modGroup) in
			let modifiersChanged = modGroup.modifiers?.contains(where: {
				$0.addedToTemplate ?? false == true
			})
			return modifiersChanged ?? false }) ?? false
		var modGroups: [ModGroup]?
		if templateChanged {
			var modGroupsToAdd: [ModGroup] = []
			self.template.modGroups?.forEach({ (modGroup) in
				var modifiersToAdd: [ModifierObject] = []
				modGroup.modifiers?.forEach({ (modifier) in
					if modifier.addedToTemplate ?? false == true {
						modifiersToAdd.append(modifier)
					}
				})
				var copy = modGroup
				copy.modifiers = modifiersToAdd
				if !modifiersToAdd.isEmpty {
					modGroupsToAdd.append(copy)
				}
			})
			modGroups = modGroupsToAdd
		}
		debugPrint("Some customisation added : \(templateChanged)")
		let hash = MD5Hash.generateHashForTemplate(itemId: item._id ?? "", modGroups: modGroups)
		HapticFeedbackGenerator.triggerVibration(type: .lightTap)
        if self.serviceType != CartUtility.getCartServiceType && CartUtility.fetchCart().isEmpty == false {
            self.showCartConflictAlert(modGroups, hash, self.item._id ?? "")
            return
        }
		addToCart?(modGroups, hash, self.item._id ?? "")
		removeFromContainer()
	}
	
	private var totalHeight: CGFloat = 0
	private var allergenExpanded: Bool = false
	private var item: MenuItem!
    private var serviceType: APIEndPoints.ServicesType = .delivery
	private weak var containerView: UIView!
	var addToCart: (([ModGroup]?, String, String) -> Void)?
	var handleDeallocation: (() -> Void)?
	private var requiredModGroups: [String] = []
	private var requiredModGroupsCriteriaSatisfed: [Bool] = []
    private var modifiersAdded: [ModifierPriceObject] = []
	
	private var template: CustomisationTemplate!
	private var baseReferenceTemplate: CustomisationTemplate!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
		setCartView(enabled: false)
	}
	
	required init?(coder adecoder: NSCoder) {
		super.init(coder: adecoder)
		commonInit()
	}
	
	@objc private func removeFromContainer() {
        self.handleDeallocation?()
//		UIView.animate(withDuration: 0.5, animations: {
//			self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: self.totalHeight)
//		}, completion: {
//			// Implementation Not Needed
//			if !$0 { return }
//			self.containerView?.subviews.forEach({
//				if $0.tag == Constants.CustomViewTags.customisationPageTag {
//					$0.removeFromSuperview()
//				}
//			})
//			self.containerView?.subviews.forEach({
//				if $0.tag == Constants.CustomViewTags.dimCustomisationBg {
//					$0.removeFromSuperview()
//				}
//			})
//		})
		
	}
	
	private func commonInit() {
		Bundle.main.loadNibNamed("CustomisableItemDetailView", owner: self, options: nil)
		addSubview(mainContentView)
		mainContentView.frame = self.bounds
		mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		cartView.isHidden = false
		tableView.roundTopCorners(cornerRadius: 32)
		cartView.roundTopCorners(cornerRadius: 4)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tapGestureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removedWithTap)))
		[ItemDetailTableViewCell.self, ModGroupHeaderCell.self, SelectDrinkTableViewCell.self, CheckMarkSelectionTableViewCell.self, AddModTypeTableViewCell.self].forEach({ self.tableView.registerCell(with: $0)})
	}
	
	@objc private func removedWithTap() {
		handleDeallocation?()
		removeFromContainer()
	}
}

extension CustomisableItemDetailView {
    func configure(item: MenuItem, container view: UIView, preLoadTemplate templateToAdd: CustomisationTemplate?, serviceType: APIEndPoints.ServicesType) {
		self.item = item
		self.containerView = view
        self.serviceType = serviceType
		self.tag = Constants.CustomViewTags.customisationPageTag
		self.center = view.center
		sortModGroupsByDrinks()
		setTemplateConfiguration(preLoadTemplate: templateToAdd)
		setCartView(enabled: !requiredModGroupsCriteriaSatisfed.contains(false))
		self.tableView.reloadData()
		calculateHeight()
		view.addSubview(self)
	}
	
	private func setTemplateConfiguration(preLoadTemplate templateToAdd: CustomisationTemplate?) {
        self.modifiersAdded.removeAll()
        self.requiredModGroupsCriteriaSatisfed.removeAll()
        configureDrinkModGroups()
		self.template = CustomisationTemplate(modGroups: self.item.modGroups ?? [], hashId: nil)
		self.item.modGroups?.forEach({ (modGroup) in
			if let typeOfModGroup = ModType(rawValue: modGroup.modType ?? ""), typeOfModGroup != .drink, modGroup.minimum ?? 0 > 0 {
				requiredModGroups.append(modGroup._id ?? "")
				requiredModGroupsCriteriaSatisfed.append(false)
			}
		})
		self.baseReferenceTemplate = self.template
		if let templateToAdd = templateToAdd {
			unsetAddedToTemplateForDrinks()
			//Need to merge templates properly here
			var modifierIdsToUpdate: [String] = []
			var modifierCountToUpdate: [Int] = []
			templateToAdd.modGroups?.forEach({ (modGroup) in
				modGroup.modifiers?.forEach({
					modifierIdsToUpdate.append($0._id ?? "")
					modifierCountToUpdate.append($0.count ?? 0)
				})
			})
			let copy = self.template
			copy?.modGroups?.forEach({ (modGroup) in
				modGroup.modifiers?.forEach({ (modifier) in
					if let index = modifierIdsToUpdate.firstIndex(where: { $0 == modifier._id ?? "" }), let updatedCount = modifierCountToUpdate[safe: index] {
						if let modGroupIndex = self.template.modGroups?.firstIndex(where: { $0._id ?? "" == modGroup._id ?? ""}), let modifierIndex = self.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0._id ?? "" == modifier._id ?? "" }) {
							self.template.modGroups?[modGroupIndex].modifiers?[modifierIndex].addedToTemplate = true
                            let templateObject = self.template.modGroups?[modGroupIndex].modifiers?[modifierIndex]
							self.template.modGroups?[modGroupIndex].modifiers?[modifierIndex].count = updatedCount
                            self.modifiersAdded.append(ModifierPriceObject(quantity: updatedCount, priceIndv: templateObject?.price ?? 0.0, id: templateObject?._id ?? ""))
							let type = ModType(rawValue: self.template.modGroups?[modGroupIndex].modType ?? "") ?? .drink
							if type == .add {
								var array: [String] = self.template.modGroups?[modGroupIndex].addTypeModifiers ?? []
								array.append(self.template.modGroups?[modGroupIndex].modifiers?[modifierIndex]._id ?? "")
								self.template.modGroups?[modGroupIndex].addTypeModifiers = array
								if let requiredIndex = self.requiredModGroups.firstIndex(where: { $0 == modGroup._id ?? "" }) {
									let count = array.count
									let minCount = modGroup.minimum ?? 0
									self.requiredModGroupsCriteriaSatisfed[requiredIndex] = count >= minCount
								}
							}
							if type == .remove || type == .replace {
								if self.template.modGroups?[modGroupIndex].checkMarkCount.isNil ?? true {
									self.template.modGroups?[modGroupIndex].checkMarkCount = 0
								}
								self.template.modGroups?[modGroupIndex].checkMarkCount! += 1
								if let requiredIndex = self.requiredModGroups.firstIndex(where: { $0 == modGroup._id ?? "" }) {
									let count = self.template.modGroups?[modGroupIndex].checkMarkCount! ?? 0
									let minCount = modGroup.minimum ?? 0
									self.requiredModGroupsCriteriaSatisfed[requiredIndex] = count >= minCount
								}
							}
							
						}
					}
				})
			})
		}
	}
	
	private func unsetAddedToTemplateForDrinks() {
		// First unset all addedToTemplate Parameters for default drink
		guard let firstDrinkModGroupIndex = self.template.modGroups?.firstIndex(where: { $0.modType ?? "" == ModType.drink.rawValue}) else { return }
		guard let firstDrinkModifierIndex = self.template.modGroups?[firstDrinkModGroupIndex].modifiers?.firstIndex(where: { $0.addedToTemplate ?? false == true }) else { return }
		self.template.modGroups?[firstDrinkModGroupIndex].modifiers?[firstDrinkModifierIndex].addedToTemplate = false
        let drinkId = self.template.modGroups?[firstDrinkModGroupIndex].modifiers?[firstDrinkModifierIndex]._id ?? ""
        self.modifiersAdded.removeAll(where: { $0.id == drinkId })
	}
	
	private func configureDrinkModGroups() {
		var drinkModGroupIds: [String] = []
		self.item.modGroups?.forEach({
			if $0.modType ?? "" == ModType.drink.rawValue {
				drinkModGroupIds.append($0._id ?? "")
			}
		})
		drinkModGroupIds.forEach({ (modGroupId) in
			guard let index = self.item.modGroups?.firstIndex(where: { $0._id ?? "" == modGroupId }) else { return }
			if self.item.modGroups?[index].modifiers?.count ?? 0 > 0 {
				var selectedIndex: Array<ModifierObject>.Index?
				selectedIndex = self.item.modGroups?[index].modifiers?.firstIndex(where: { DrinkSize(rawValue: $0.drinkSize ?? "") == .regular })
				if selectedIndex.isNil {
					selectedIndex = self.item.modGroups?[index].modifiers?.firstIndex(where: { DrinkSize(rawValue: $0.drinkSize ?? "") == .medium })
				}
				if selectedIndex.isNil {
					selectedIndex = self.item.modGroups?[index].modifiers?.firstIndex(where: { DrinkSize(rawValue: $0.drinkSize ?? "") == .large })
				}
				guard let selectedIndex = selectedIndex else { return }
				self.item.modGroups?[index].modifiers?[selectedIndex].addedToTemplate = true
                let modifier = self.item.modGroups?[index].modifiers?[selectedIndex]
                self.modifiersAdded.append(ModifierPriceObject(quantity: 1, priceIndv: modifier?.price ?? 0.0, id: modifier?._id ?? ""))
				let drinkSize = self.item.modGroups?[index].modifiers?[selectedIndex].drinkSize ?? ""
				self.item.modGroups?[index].selectedDrinkSizeInApp = drinkSize
			}
			
		})
	}
	
	private func sortModGroupsByDrinks() {
		let drinkModGroupElements = self.item.modGroups?.filter({
			guard let modType = ModType(rawValue: $0.modType ?? "") else { return false }
			return modType == .drink
		})
		if drinkModGroupElements.isNotNil {
			let nonDrinkModGroups = self.item.modGroups?.filter({
				guard let modType = ModType(rawValue: $0.modType ?? "") else { return false }
				return modType != .drink
			})
			self.item.modGroups = []
			self.item.modGroups?.append(contentsOf: drinkModGroupElements!)
			self.item.modGroups?.append(contentsOf: nonDrinkModGroups ?? [])
		}
	}
	
	private func calculateHeight() {
//		let window = UIApplication.shared.windows.first
        let bottomPadding: CGFloat = 0//window?.safeAreaInsets.bottom
        debugPrint("Safe Area Bottom : \(bottomPadding )")
		var tableHeight: CGFloat = 0
		for cell in tableView.visibleCells {
			tableHeight += cell.bounds.height
		}
		debugPrint("Total tableview height after reload : \(tableHeight)")
        let totalHeight = tableHeight + 16 + 32 + 70
		//70 is for cart
		let difference = self.containerView.height - totalHeight
		if difference >= 99 {
			self.topPaddingConstraint.constant = difference
		}
		// else topPadding = 99 which it already is
		self.totalHeight = totalHeight
	//	bottomSheet.transform = CGAffineTransform(translationX: 0, y: totalHeight)
	}
}

extension CustomisableItemDetailView: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1 + (template.modGroups?.count ?? 0)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		}
		let modGroup = template.modGroups?[section - 1]
		guard let modGroupType = ModType(rawValue: modGroup?.modType ?? "") else {
			return 0 }
		switch modGroupType {
		case .drink:
			return 2
		default:
			return 1 + (modGroup?.modifiers?.count ?? 0)
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = indexPath.section
		let row = indexPath.row
		if section == 0 {
			return getItemDetailCell(tableView, cellForRowAt: indexPath)
		}
		guard let modGroup = template.modGroups?[safe: section - 1] else { return UITableViewCell() }
		
		if row == 0 {
			return getModGroupHeaderCell(tableView, cellForRowAt: indexPath, modGroup: modGroup)
		}
		
		return getModGroupSpecificCell(tableView, cellForRowAt: indexPath, modGroup: modGroup)
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let section = indexPath.section
		let row = indexPath.row
		if section == 0 {
			return
		}
		guard let modGroup = template.modGroups?[safe: section - 1] else { return }
		if row == 0 {
			return
		}
		
		guard let modGroupType = ModType(rawValue: modGroup.modType ?? "") else { return }
		
		switch modGroupType {
		case .drink:
			break
		case .add:
			let cell = tableView.dequeueCell(with: AddModTypeTableViewCell.self)
			cell.modifierImgView.kf.cancelDownloadTask()
		case .remove, .replace:
			let cell = tableView.dequeueCell(with: CheckMarkSelectionTableViewCell.self)
			cell.modifierImgView.kf.cancelDownloadTask()
		}
		
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if scrollView.contentOffset.y <= 0 {
			scrollView.contentOffset = CGPoint.zero
		}
	}
}

extension CustomisableItemDetailView {
	private func getItemDetailCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: ItemDetailTableViewCell.self)
		debugPrint("Cell received width : \(containerView.width)")
		cell.configure(item: self.item, expandedState: self.allergenExpanded, containerWidth: containerView.width)
		return cell
	}
	
	private func getModGroupHeaderCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, modGroup: ModGroup) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: ModGroupHeaderCell.self)
		let title = AppUserDefaults.selectedLanguage() == .en ? modGroup.title ?? "" : modGroup.titleUn ?? ""
		let required = ModType(rawValue: modGroup.modType ?? "") == .drink || (modGroup.minimum ?? 0) > 0
		cell.configure(title: title.byRemovingLeadingTrailingWhiteSpaces, isRequired: required, modGroup: modGroup)
		return cell
	}
	
	private func getModGroupSpecificCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, modGroup: ModGroup) -> UITableViewCell {
		guard let modGroupType = ModType(rawValue: modGroup.modType ?? "") else {
			return UITableViewCell() }
		
		switch modGroupType {
		case .drink:
			return getDrinkModGroupCell(tableView, cellForRowAt: indexPath, modGroup: modGroup)
		case .add:
			return getAddModTypeTableViewCell(tableView, cellForRowAt: indexPath, modGroup: modGroup)
		case .remove, .replace:
			return getCheckMarkTableViewCell(tableView, cellForRowAt: indexPath, modGroup: modGroup)
		}
	}
}

extension CustomisableItemDetailView {
	private func getDrinkModGroupCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, modGroup: ModGroup) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: SelectDrinkTableViewCell.self)
		cell.configure(drinkModGroup: modGroup)
		cell.drinkSizeSelectionChanged = { [weak self] (selectedSize, modGroupId, previouslySelectedModId) in
			guard let strongSelf = self, let modGroupIndex = strongSelf.template.modGroups?.firstIndex(where: { $0._id ?? "" == modGroupId }) else { return }
			strongSelf.template.modGroups?[modGroupIndex].selectedDrinkSizeInApp = selectedSize
			if let oldModifierIndex = strongSelf.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0._id ?? "" == previouslySelectedModId }) {
				strongSelf.template.modGroups?[modGroupIndex].modifiers?[oldModifierIndex].addedToTemplate = false
                let oldDrinkId = strongSelf.template.modGroups?[modGroupIndex].modifiers?[oldModifierIndex]._id ?? ""
                strongSelf.modifiersAdded.removeAll(where: { $0.id == oldDrinkId })
			}
			if let newModifierIndex = strongSelf.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0.drinkSize ?? "" == selectedSize }) {
				strongSelf.template.modGroups?[modGroupIndex].modifiers?[newModifierIndex].addedToTemplate = true
                let newDrink = strongSelf.template.modGroups?[modGroupIndex].modifiers?[newModifierIndex]
                strongSelf.modifiersAdded.append(ModifierPriceObject(quantity: 1, priceIndv: newDrink?.price ?? 0.0, id: newDrink?._id ?? ""))
			}
            strongSelf.setCartView(enabled: !strongSelf.requiredModGroupsCriteriaSatisfed.contains(false))
			strongSelf.tableView.reloadData()
		}
		cell.drinkSelectionChanged = { [weak self] (oldModifierId, newModifierId, modGroupId) in
			guard let strongSelf = self, let modGroupIndex = strongSelf.template.modGroups?.firstIndex(where: { $0._id ?? "" == modGroupId }) else { return }
			if let oldModifierIndex = strongSelf.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0._id ?? "" == oldModifierId }) {
				strongSelf.template.modGroups?[modGroupIndex].modifiers?[oldModifierIndex].addedToTemplate = false
                let oldDrinkId = strongSelf.template.modGroups?[modGroupIndex].modifiers?[oldModifierIndex]._id ?? ""
                strongSelf.modifiersAdded.removeAll(where: { $0.id == oldDrinkId })
			}
			if let newModifierIndex = strongSelf.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0._id ?? "" == newModifierId }) {
				strongSelf.template.modGroups?[modGroupIndex].modifiers?[newModifierIndex].addedToTemplate = true
                let newDrink = strongSelf.template.modGroups?[modGroupIndex].modifiers?[newModifierIndex]
                strongSelf.modifiersAdded.append(ModifierPriceObject(quantity: 1, priceIndv: newDrink?.price ?? 0.0, id: newDrink?._id ?? ""))
			}
            strongSelf.setCartView(enabled: !strongSelf.requiredModGroupsCriteriaSatisfed.contains(false))
			strongSelf.tableView.reloadData()
		}
		return cell
	}
	
	private func getCheckMarkTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, modGroup: ModGroup) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: CheckMarkSelectionTableViewCell.self)
		if let modifier = modGroup.modifiers?[indexPath.row - 1], let modGroupId = modGroup._id {
			let currentCount = modGroup.checkMarkCount ?? 0
			let maxCount = modGroup.maximum ?? 0
			var allowAddingMore = currentCount < maxCount
            if maxCount == 0 || (modGroup.minimum ?? 0) == 0 {
				allowAddingMore = true
			}
			cell.configure(modifier: modifier, modGroupId: modGroupId, allowAddingMore: allowAddingMore)
		}
		cell.checkMarkPressed = { [weak self] (state, modifierId, modGroupId) in
			guard let strongSelf = self, let modGroupIndex = strongSelf.template.modGroups?.firstIndex(where: { $0._id ?? "" == modGroupId }), let modifierIndex = strongSelf.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0._id ?? "" == modifierId }) else { return }
			let previousCount = strongSelf.template.modGroups?[modGroupIndex].checkMarkCount ?? 0
			if state == false {
				strongSelf.template.modGroups?[modGroupIndex].checkMarkCount = previousCount - 1 < 0 ? 0 : previousCount - 1
			} else {
				strongSelf.template.modGroups?[modGroupIndex].checkMarkCount = previousCount + 1
			}
			strongSelf.template.modGroups?[modGroupIndex].modifiers?[modifierIndex].addedToTemplate = state
            if state == false {
                strongSelf.modifiersAdded.removeAll(where: { $0.id == modifierId })
            } else {
                let modiiferToAdd = strongSelf.template.modGroups?[modGroupIndex].modifiers?[modifierIndex]
                strongSelf.modifiersAdded.append(ModifierPriceObject(quantity: 1, priceIndv: modiiferToAdd?.price ?? 0.0, id: modiiferToAdd?._id ?? ""))
            }
			if let requiredIndex = strongSelf.requiredModGroups.firstIndex(where: { $0 == modGroupId }) {
				let count = strongSelf.template.modGroups?[modGroupIndex].checkMarkCount ?? 0
				let minCount = modGroup.minimum ?? 0
				strongSelf.requiredModGroupsCriteriaSatisfed[requiredIndex] = count >= minCount
			}
            strongSelf.setCartView(enabled: !strongSelf.requiredModGroupsCriteriaSatisfed.contains(false))
			strongSelf.tableView.reloadData()
		}
		return cell
	}
	
	private func getAddModTypeTableViewCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, modGroup: ModGroup) -> UITableViewCell {
		let cell = tableView.dequeueCell(with: AddModTypeTableViewCell.self)
		if let modifier = modGroup.modifiers?[indexPath.row - 1], let modGroupId = modGroup._id {
			let currentCount = modGroup.addTypeModifiers?.count ?? 0
			let maxCount = modGroup.maximum ?? 0
			var allowOperation = currentCount < maxCount
			if maxCount == 0 {
				allowOperation = true
			}
			cell.configure(modifier: modifier, modGroupId: modGroupId, allowOperation: allowOperation)
		}
		cell.modifierCountAltered = { [weak self] (count, modifierId, modGroupId) in
			guard let strongSelf = self, let modGroupIndex = strongSelf.template.modGroups?.firstIndex(where: { $0._id ?? "" == modGroupId }), let modifierIndex = strongSelf.template.modGroups?[modGroupIndex].modifiers?.firstIndex(where: { $0._id ?? "" == modifierId }) else { return }
			var previousArray = strongSelf.template.modGroups?[modGroupIndex].addTypeModifiers ?? []
			if count == 0 {
				previousArray.remove(object: modifierId)
				strongSelf.template.modGroups?[modGroupIndex].addTypeModifiers = previousArray
			} else {
				if !previousArray.contains(modifierId) {
					previousArray.append(modifierId)
				}
				strongSelf.template.modGroups?[modGroupIndex].addTypeModifiers = previousArray
			}
			strongSelf.template.modGroups?[modGroupIndex].modifiers?[modifierIndex].count = count
			strongSelf.template.modGroups?[modGroupIndex].modifiers?[modifierIndex].addedToTemplate = count != 0
            let modifierAddToAlter = strongSelf.template.modGroups?[modGroupIndex].modifiers?[modifierIndex]
            if count != 0 {
                if let alreadyExists = strongSelf.modifiersAdded.firstIndex(where: { $0.id == modifierAddToAlter?._id ?? ""}) {
                    strongSelf.modifiersAdded[alreadyExists].quantity = count
                } else {
                    strongSelf.modifiersAdded.append(ModifierPriceObject(quantity: count, priceIndv: modifierAddToAlter?.price ?? 0.0, id: modifierAddToAlter?._id ?? ""))
                }
            } else {
                strongSelf.modifiersAdded.removeAll(where: { $0.id == modifierAddToAlter?._id ?? ""})
              //  strongSelf.modifiersTotalPrice -= strongSelf.template.modGroups?[modGroupIndex].modifiers?[modifierIndex].price ?? 0.0
            }
			if let requiredIndex = strongSelf.requiredModGroups.firstIndex(where: { $0 == modGroupId }) {
				let count = strongSelf.template.modGroups?[modGroupIndex].addTypeModifiers?.count ?? 0
				let minCount = modGroup.minimum ?? 0
				strongSelf.requiredModGroupsCriteriaSatisfed[requiredIndex] = count >= minCount
			}
            strongSelf.setCartView(enabled: !strongSelf.requiredModGroupsCriteriaSatisfed.contains(false))
			strongSelf.tableView.reloadData()
		}
		return cell
	}
}

extension CustomisableItemDetailView {
	private func setCartView(enabled: Bool) {
        //safeAreaPaddingView.backgroundColor = enabled ? AppColors.kuduThemeYellow : UIColor(r: 239, g: 239, b: 239, alpha: 1)
		//cartView.backgroundColor = enabled ? AppColors.kuduThemeYellow : UIColor(r: 239, g: 239, b: 239, alpha: 1)
        safeAreaMinGradientImage.isHidden = enabled ? false : true
        cartBannerGradientImage.isHidden = enabled ? false : true
        safeAreaGradientImage.isHidden = enabled ? false : true
        addButton.backgroundColor = enabled ? .white : UIColor(r: 239, g: 239, b: 239, alpha: 1)
        addButton.borderWidth = enabled ? 0 : 1
		addButton.borderColor = enabled ? .clear : UIColor(r: 91, g: 90, b: 90, alpha: 1)
        addButton.setTitleColor(enabled ? AppColors.kuduThemeBlue : UIColor(r: 91, g: 90, b: 90, alpha: 1), for: .normal)
        cartLabel.textColor = enabled ? AppColors.black : UIColor(r: 91, g: 90, b: 90, alpha: 1)
        let itemPrice = self.item?.price ?? 0.0
        var customisationPrice: Double = 0
        modifiersAdded.forEach({
            customisationPrice += (Double($0.quantity))*($0.priceIndv)
        })
        let total = (itemPrice + customisationPrice).removeZerosFromEnd()
        cartLabel.text = "1 item | SR \(total)"
	}
}

extension CustomisableItemDetailView {
    private func showCartConflictAlert(_ modGroups: [ModGroup]?, _ hashId: String, _ itemId: String) {
        let alert = AppPopUpView(frame: CGRect(x: 0, y: 0, width: 288, height: 186))
        alert.setTextAlignment(.left)
        alert.setButtonConfiguration(for: .left, config: .blueOutline, buttonLoader: nil)
        alert.setButtonConfiguration(for: .right, config: .yellow, buttonLoader: .right)
        alert.configure(title: "Change Order Type ?", message: "Please be aware your cart will be cleared as you change order type", leftButtonTitle: "Cancel", rightButtonTitle: "Continue", container: self)
        alert.handleAction = { [weak self] in
            if $0 == .right {
                CartUtility.clearCart(clearedConfirmed: {
                    guard let strongSelf = self else { return }
                    strongSelf.addToCart?(modGroups, hashId, itemId)
                    weak var weakRef = alert
                    weakRef?.removeFromContainer()
                    strongSelf.removeFromContainer()
                })
                
            }
        }
    }
}
