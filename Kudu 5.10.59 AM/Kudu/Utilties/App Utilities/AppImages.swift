//
//  AppImages.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import UIKit

final class AppImages {
    
    struct MainImages {
        static var kuduLogoWithText: UIImage { #imageLiteral(resourceName: "kuduLogoWithText") }
        static var blackCross: UIImage { #imageLiteral(resourceName: "blackCross") }
        static var clearCross: UIImage { #imageLiteral(resourceName: "clearCross") }
        static var unlikedHeart: UIImage { #imageLiteral(resourceName: "k_explore_unlikedOutline") }
        static var likedHeart: UIImage { #imageLiteral(resourceName: "k_heart_liked") }
        static var fixedPlaceholder: UIImage { #imageLiteral(resourceName: "k_kudu_fixedPlaceholder") }
    }
    
    struct LanguagePrefScreen {
       static var selected: UIImage { #imageLiteral(resourceName: "selectedGreenCircle") }
       static var unSelected: UIImage { #imageLiteral(resourceName: "unselectedCircle") }
    }
    
    struct LoginScreen {
        static var successCircle: UIImage { #imageLiteral(resourceName: "k_login_greenCircleCheck") }
        static var failureCircle: UIImage { #imageLiteral(resourceName: "k_login_redCircleCross") }
    }
    
    struct Home {
        static var footerImg: UIImage { #imageLiteral(resourceName: "k_home_footerView") }
    }
    
    struct AddAddress {
        static var checkBoxUnselected: UIImage { #imageLiteral(resourceName: "k_myaddress_grayUncheck") }
        static var checkBoxSelected: UIImage { #imageLiteral(resourceName: "k_myaddress_yellowChecked") }
        static var radioUnselected: UIImage { #imageLiteral(resourceName: "k_myaddress_radioUnselected") }
        static var radioSelected: UIImage { #imageLiteral(resourceName: "k_myaddress_radioSelected") }
    }
    
    struct SendFeedback {
        static var cameraPermissionDenied: UIImage { #imageLiteral(resourceName: "k_mysettings_camerapermissionDenied") }
        static var galleryPermissionDenied: UIImage { #imageLiteral(resourceName: "k_mysettings_gallerypermissionDenied") }
    }
    
    struct SetDeliveryLocation {
        static var home: UIImage { #imageLiteral(resourceName: "k_set_location_home") }
        static var work: UIImage { #imageLiteral(resourceName: "k_set_location_work") }
        static var pinMarker: UIImage { #imageLiteral(resourceName: "k_autcomplete_pinMarker") }
    }
    
    struct SetRestaurantMap {
        static var markerLarge: UIImage { #imageLiteral(resourceName: "k_restaurant_marker_large") }
        static var markerSmall: UIImage { #imageLiteral(resourceName: "k_restaurant_marker_small") }
        static var work: UIImage { #imageLiteral(resourceName: "signup_name") }
    }
    
    struct NotificationPref {
       static var switchSelected: UIImage { #imageLiteral(resourceName: "k_selected_switch") }
       static var switchUnselected: UIImage { #imageLiteral(resourceName: "k_unselected_switch") }
    }
    
    struct OurStore {
        static var mapPinMark: UIImage { #imageLiteral(resourceName: "Group 20260.png") }
        static var storeImagePlaceholder: UIImage { UIImage(named: "k_storeImage") ?? UIImage() }
    }
    struct ExploreMenu {
        static var drinkImage: UIImage { UIImage(named: "k_exploreMenu_drinkImage_placeholder") ?? UIImage() }
        static var cellGradient: UIImage { UIImage(named: "k_exploreMenu_cellGradient") ?? UIImage() }
    }
}
