//
//  MultipleCarouselVM.swift
//  Kudu
//
//  Created by Admin on 27/09/22.
//

import Foundation

class MultipleCarouselVM {
    private var items: [MenuItem] = []
    private var ids: [String] = []
    var getItems: [MenuItem] { items }
    
    func configure(idsToFetch: [String]) {
        self.ids = idsToFetch
    }
    
    func fetchDetails(completed: @escaping ((Result<Bool, Error>) -> Void)) {
        var idsFetched: [String] = []
        ids.forEach({
            APIEndPoints.HomeEndPoints.getItemDetail(itemId: $0, success: { [weak self] in
                guard let item = $0.data?.first else {
                    completed(.failure(NSError(localizedDescription: "Could not fetch details")))
                    return }
                self?.items.append(item)
                idsFetched.append(item._id ?? "")
                if idsFetched.count == self?.ids.count ?? 0 {
                    completed(.success(true))
                }
            }, failure: { (error) in
                completed(.failure(NSError(code: error.code, localizedDescription: error.msg)))
            })
        })
    }
}
