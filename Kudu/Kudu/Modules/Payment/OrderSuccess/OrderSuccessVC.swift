//
//  OrderSuccessVC.swift
//  Kudu
//
//  Created by Admin on 30/09/22.
//

import UIKit
import AVFoundation

class OrderSuccessVC: BaseVC {
    
    var flow: CartPageFlow!
    
    @IBAction func doneButton(_ sender: Any) {
        switch flow {
        case .fromExplore:
            self.popToSpecificViewController(kindOf: ExploreMenuV2VC.self)
        case .fromHome:
            self.popToSpecificViewController(kindOf: HomeVC.self)
        case .fromFavourites:
            self.popToSpecificViewController(kindOf: MyFavouritesVC.self)
        case .fromMyOffers:
            break
        case .none:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.postNotificationForObservers(.clearCartEverywhere)
        
        // Payment success sound
        let systemSoundID: SystemSoundID = 1394
        
        // to play sound
        AudioServicesPlaySystemSound(systemSoundID)
    }
}
