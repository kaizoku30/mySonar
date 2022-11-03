//
//  RatingViewModel.swift
//  Kudu
//
//  Created by Harpreet Kaur on 2022-10-11.
//

import Foundation
protocol RatingViewModelDelegate: AnyObject {
    func ratingReponseHandling(responseType: Result<Bool, Error>)
}

class RatingViewModel {
    
    private let webService = APIEndPoints.HomeEndPoints.self
    weak var delegate: RatingViewModelDelegate?
   
    func validateData(req: RatingRequestModel) -> (validData: Bool, errorMsg: String?) {
        if req.rate == 0 {
            return (false, LocalizedStrings.Rating.rating)
        }
        
        if req.description == "" {
            return (false, LocalizedStrings.Rating.description)
        }
        self.hitRatingAPI(req: req)
        return (true, nil)
    }
    
    func hitRatingAPI(req: RatingRequestModel) {
        APIEndPoints.OrderEndPoints.rateOrder(req: req, success: { [weak self] _ in
            NotificationCenter.postNotificationForObservers(.updateOrderObject)
            self?.delegate?.ratingReponseHandling(responseType: .success(true))
        }, failure: { [weak self] in
            let error = NSError(code: $0.code, localizedDescription: $0.msg)
            self?.delegate?.ratingReponseHandling(responseType: .failure(error))
        })
    }
    
}
