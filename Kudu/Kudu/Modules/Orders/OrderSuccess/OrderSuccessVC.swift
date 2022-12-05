//
//  OrderSuccessVC.swift
//  Kudu
//
//  Created by Admin on 30/09/22.
//

import UIKit
import AVFoundation

class OrderSuccessVC: BaseVC {
    
    @IBOutlet private weak var thankYouForUsingKuduLbl: UILabel!
    @IBOutlet private weak var yourOrderIsConfirmedLbl: UILabel!
    @IBOutlet private weak var thankYouLbl: UILabel!
    
    var flow: CartPageFlow!
    
    @IBAction func doneButton(_ sender: Any) {
        
        if self.navigationController?.viewControllers.contains(where: { $0.isKind(of: ExploreMenuV2VC.self )}) ?? false {
            self.popToSpecificViewController(kindOf: ExploreMenuV2VC.self)
            return
        }
        
        if self.navigationController?.viewControllers.contains(where: { $0.isKind(of: MyFavouritesVC.self  )}) ?? false {
            self.popToSpecificViewController(kindOf: MyFavouritesVC.self)
            return
        }
        
        if self.navigationController?.viewControllers.contains(where: { $0.isKind(of: HomeVC.self )}) ?? false {
            self.popToSpecificViewController(kindOf: HomeVC.self)
            return
        }
        
        if self.navigationController?.viewControllers.contains(where: { $0.isKind(of: ProfileVC.self)}) ?? false {
            self.popToSpecificViewController(kindOf: ProfileVC.self)
            return
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.postNotificationForObservers(.syncCartBanner)
    }
}
