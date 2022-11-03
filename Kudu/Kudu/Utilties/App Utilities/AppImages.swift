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
        static var unlikedHeart: UIImage { #imageLiteral(resourceName: "k_unlikedGIFStartFrame") }
        static var likedHeart: UIImage { #imageLiteral(resourceName: "k_likedGIFStartFrame") }
        static var placeholder16x9: UIImage { #imageLiteral(resourceName: "k_placeholder_16x9") }
        static var fixedPlaceholder: UIImage { #imageLiteral(resourceName: "k_kudu_fixedPlaceholder") }
        static var notificationBell: UIImage { #imageLiteral(resourceName: "k_notification_yes") }
        static var noNotificationBell: UIImage { #imageLiteral(resourceName: "k_notification_no") }
        
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
       
        static var delete: UIImage { #imageLiteral(resourceName: "k_exploreMenu_delete") }
        static var minus: UIImage { #imageLiteral(resourceName: "k_explore_minusBtn") }
        static var drinkImage: UIImage { UIImage(named: "k_exploreMenu_drinkImage_placeholder") ?? UIImage() }
        static var cellGradient: UIImage { UIImage(named: "k_exploreMenu_cellGradient") ?? UIImage() }
    }
    
    struct Customise {
        static var delete: UIImage { #imageLiteral(resourceName: "k_customise_redDelete") }
        static var activePlus: UIImage { #imageLiteral(resourceName: "k_customise_activePlus") }
        static var disabledPlus: UIImage { #imageLiteral(resourceName: "k_customise_disabledPlus") }
        static var minus: UIImage { #imageLiteral(resourceName: "k_customise_minus") }
    }
	
	struct Cart {
		static var upArrow: UIImage { #imageLiteral(resourceName: "k_cart_upArrow") }
		static var downArrow: UIImage { #imageLiteral(resourceName: "k_cart_downArrow") }
	}
    
    struct VehicleDetails {
        static var selectedCheck: UIImage { #imageLiteral(resourceName: "k_vehicle_check") }
    }
    
    struct TabBar {
        static var profileUnselected: UIImage { #imageLiteral(resourceName: "k_profile_Unselected") }
        static var profileSelected: UIImage { #imageLiteral(resourceName: "k_profile_selected") }
        static var ourStoreUnSelected: UIImage { #imageLiteral(resourceName: "k_ourStore_unSelected") }
        static var ourStoreSelected: UIImage { #imageLiteral(resourceName: "k_ourStore_selected") }
        static var menuUnselected: UIImage { #imageLiteral(resourceName: "k_menu_unSelected") }
        static var menuSelected: UIImage { #imageLiteral(resourceName: "k_tab_menuSelected") }
        static var homeUnselected: UIImage { #imageLiteral(resourceName: "k_tab_home_unSelected") }
        static var homeSelected: UIImage { #imageLiteral(resourceName: "k_tab_home_selected") }
    }
    
    struct Orders {
        static var successOrderListImg: UIImage { #imageLiteral(resourceName: "k_boxOfFood") }
        static var cancelOrderListImg: UIImage { #imageLiteral(resourceName: "k_cancelledOrderList") }
        static var redExclamation: UIImage { #imageLiteral(resourceName: "k_redExclamation") }
        static var cancelCircle: UIImage { #imageLiteral(resourceName: "k_cancelCircle") }
    }
}
