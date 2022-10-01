//
//  ChangeDefaultAddressView.swift
//  Kudu
//
//  Created by Admin on 19/07/22.
//

import UIKit

class ChangeDefaultAddressView: UIView {

    @IBOutlet private weak var actionSheet: UIView!
    @IBOutlet private weak var bottomSheet: UIView!
    @IBOutlet private weak var dismissButton: AppButton!
    @IBOutlet private var mainContentView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var saveButton: AppButton!
    static var ContentHeight: CGFloat { 545 }
    private weak var containerView: UIView?
    private var list: [MyAddressListItem] = []
    private var idToDelete: String = ""
    private var selectedIndex: Int = 0
    private var editFlow = false
    var operationComplete: ((String) -> Void)?
    var editFlowCompletion: (([MyAddressListItem]) -> Void)?
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder adecoder: NSCoder) {
         super.init(coder: adecoder)
         commonInit()
     }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let selectedItem = list.filter({ ($0.isDefault ?? false) == true })
        if let item = selectedItem.first {
            self.saveButton.startBtnLoader()
            self.isUserInteractionEnabled = false
            if self.editFlow {
                editFlowCompletion?(list)
            }
            self.updateAddresss(item)
        }
    }
    
    @IBAction private func dismissButtonPressed(_ sender: Any) {
        removeFromContainer()
    }
    
      private func commonInit() {
        Bundle.main.loadNibNamed("ChangeDefaultAddressView", owner: self, options: nil)
        addSubview(mainContentView)
        mainContentView.frame = self.bounds
        mainContentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: AddressOptionTableCell.self)
        actionSheet.roundTopCorners(cornerRadius: 32)
        bottomSheet.transform = CGAffineTransform(translationX: 0, y: ChangeDefaultAddressView.ContentHeight)
     }
    
    private func removeFromContainer() {
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
    }
    
    func configure(container view: UIView, list: [MyAddressListItem], idToDelete: String) {
        self.idToDelete = idToDelete
        setView(container: view, list: list)
    }
    
    func configureForEditFlow(container view: UIView, list: [MyAddressListItem]) {
        self.editFlow = true
        setView(container: view, list: list)
    }
    
    private func setView(container view: UIView, list: [MyAddressListItem]) {
        self.containerView = view
        self.list = list
        if list.count > 0 {
            self.list[0].isDefault = true
        }
        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .black.withAlphaComponent(0.5)
        dimmedView.tag = Constants.CustomViewTags.dimViewTag
        view.addSubview(dimmedView)
        self.tag = Constants.CustomViewTags.alertTag
        self.center = view.center
        view.addSubview(self)
        UIView.animate(withDuration: 1, animations: {
            self.bottomSheet.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: {
            if $0 {
                self.tableView.reloadData()
            }
        })
    }

}

extension ChangeDefaultAddressView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= list.count {
            return UITableViewCell() }
        let cell = tableView.dequeueCell(with: AddressOptionTableCell.self)
        cell.configure(item: self.list[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < list.count, selectedIndex < list.count {
            self.list[selectedIndex].isDefault = false
            self.selectedIndex = indexPath.row
            self.list[indexPath.row].isDefault = !(self.list[indexPath.row].isDefault ?? true)
            self.tableView.reloadData()
        }
    }
}

extension ChangeDefaultAddressView {
    private func updateAddresss(_ item: MyAddressListItem) {
        APIEndPoints.AddressEndPoints.editAddress(addressId: item.id ?? "", request: item.convertToRequest(), success: { [weak self] _ in
            self?.operationComplete?(self?.idToDelete ?? "")
            self?.removeFromContainer()
        }, failure: { [weak self] in
            self?.saveButton.stopBtnLoader()
            self?.isUserInteractionEnabled = true
            SKToast.show(withMessage: $0.msg)
        })
    }
}
