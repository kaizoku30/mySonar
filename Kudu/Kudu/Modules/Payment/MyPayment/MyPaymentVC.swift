//
//  MyPaymentVC.swift
//  Kudu
//
//  Created by Admin on 21/10/22.
//

import UIKit

class MyPaymentVC: BaseVC {
    @IBOutlet private weak var baseView: MyPaymentView!
    private let viewModel = MyPaymentVM()
    private var isFetchingCards: Bool = true
    private var deleteInConsideration: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    private func initialSetup() {
        baseView.popVC = { [weak self] in
            self?.pop()
        }
        self.baseView.refreshTable()
        self.viewModel.getCards(fetched: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.isFetchingCards = false
            switch $0 {
            case .success:
                strongSelf.baseView.refreshTable()
            case .failure(let error):
                strongSelf.baseView.hideTableView(hide: true)
                strongSelf.baseView.showError(msg: error.localizedDescription)
            }
        })
    }
}

extension MyPaymentVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFetchingCards {
            return 4
        } else {
            self.baseView.hideTableView(hide: self.viewModel.getCards.isEmpty)
            return viewModel.getCards.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isFetchingCards {
            let cell = tableView.dequeueCell(with: MyPaymentShimmerCell.self)
            return cell
        }
        
        let cell = tableView.dequeueCell(with: MyPaymentCardCell.self)
        cell.deleteCardAtIndex = { [weak self] in
            self?.deleteInConsideration = $0
            self?.handleDelete()
        }
        let card = viewModel.getCards[indexPath.row]
        cell.configure(holderName: card.cardHolderName ?? "", last4: card.last4 ?? "", cardImage: card.getCardImage(), index: indexPath.row)
        return cell
    }
}

extension MyPaymentVC {
    private func handleDelete() {
        self.baseView.showDeletePopUp(deleteCard: { [weak self] in
            self?.isFetchingCards = true
            self?.baseView.refreshTable()
            let deleteId = self?.viewModel.getCards[self?.deleteInConsideration ?? 0].id ?? ""
            self?.viewModel.deleteCard(cardId: deleteId, done: { [weak self] in
                switch $0 {
                case .success:
                    self?.refreshList()
                case .failure(let error):
                    self?.isFetchingCards = false
                    self?.baseView.refreshTable()
                    self?.baseView.showError(msg: error.localizedDescription)
                }
            })
        })
    }
    
    private func refreshList() {
        self.viewModel.getCards(fetched: { [weak self] in
            switch $0 {
            case .success:
                self?.isFetchingCards = false
                self?.baseView.refreshTable()
            case .failure(let error):
                self?.isFetchingCards = false
                self?.baseView.refreshTable()
                self?.baseView.showError(msg: error.localizedDescription)
            }
        })
    }
}
