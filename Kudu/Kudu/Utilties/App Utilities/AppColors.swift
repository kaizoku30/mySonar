//
//  AppColors.swift
//  Kudu
//
//  Created by Admin on 02/05/22.
//

import Foundation
import UIKit

final class AppColors: UIColor {
    
    struct LanguagePrefScreen {
       static var selectedBorder: UIColor { #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.45) }
       static var unselectedBorder: UIColor { #colorLiteral(red: 0.8156862745, green: 0.8156862745, blue: 0.8156862745, alpha: 0.34) }
    }
    
    struct LoginScreen {
        static var unselectedButtonBg: UIColor { #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1) }
        static var unselectedButtonTextColor: UIColor { #colorLiteral(red: 0.3568627451, green: 0.3529411765, blue: 0.3529411765, alpha: 0.5) }
        static var selectedBgButtonColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.1058823529, alpha: 1) }
    }
    
    struct SignUpScreen {
        static var termsAndConditionsGrey: UIColor { #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1) }
    }
    
    struct PhoneVerificationScreen {
        static var trackColorGrey: UIColor { #colorLiteral(red: 0.9499530196, green: 0.9499530196, blue: 0.9499530196, alpha: 1) }
        static var progressColorYellow: UIColor { #colorLiteral(red: 0.9732094407, green: 0.7451413274, blue: 0.1295291781, alpha: 1) }
        static var resendButtonColor: UIColor { #colorLiteral(red: 0.9732094407, green: 0.7451413274, blue: 0.1295291781, alpha: 1) }
        static var differentNumLabel: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6) }
    }
    
    struct HomeScreen {
        static var homeTableBG: UIColor { #colorLiteral(red: 0.9725490196, green: 0.9843137255, blue: 1, alpha: 1) }
        static var selectedButtonBorder: UIColor { #colorLiteral(red: 0.337254902, green: 0.4705882353, blue: 0.5960784314, alpha: 0.66) }
        static var buttonColor: UIColor { #colorLiteral(red: 0.1490196078, green: 0.2549019608, blue: 0.3490196078, alpha: 1) }
    }
    
    struct MyAddressScreen {
        static var tableBG: UIColor { #colorLiteral(red: 0.9725490196, green: 0.9843137255, blue: 1, alpha: 1) }
        static var deleteBtnColor: UIColor { #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1) }
    }
    
    struct AddNewAddress {
        static var disabledTextColor: UIColor { #colorLiteral(red: 0.7261298299, green: 0.7544546127, blue: 0.7811719775, alpha: 1) }
    }
    
    struct SendFeedbackScreen {
        //textfieldBg
        static var textfieldBg: UIColor { #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 0.2) }
        static var placeholderTextColor: UIColor { #colorLiteral(red: 0.4470588235, green: 0.4470588235, blue: 0.4470588235, alpha: 1) }
        static var deleteBtnColor: UIColor { #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1) }
    }
    
    struct ExploreMenuScreen {
        static var disabledText: UIColor { #colorLiteral(red: 0.4470588235, green: 0.4470588235, blue: 0.4470588235, alpha: 0.7) }
        static var searhBarBg: UIColor { #colorLiteral(red: 0.8926360011, green: 0.8926360011, blue: 0.8926360011, alpha: 0.1) }
        static var selectedDrinkSize: UIColor { #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.1058823529, alpha: 1) }
        static var selectedDrinkSizeBackgroundColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.1058823529, alpha: 0.01728062914) }
        static var unselectedDrinkSizeBorderColor: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.06164631623) }
        static var unselectedDrinkSizeTextColor: UIColor { #colorLiteral(red: 0.168627451, green: 0.168627451, blue: 0.168627451, alpha: 1) }
        static var unselectedDrinksizeBackgroundColor: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
        static var unselectedDrinkTypeBorderColor: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.05975786424) }
        static var unselectedDrinkTypeBakgroundColor: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) }
        static var selectedDrinkTypeBorderColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.1058823529, alpha: 1) }
        static var selectDrinkTypeBackgroundColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.1058823529, alpha: 0.07584850993) }
        static var addButtonUnavailable: UIColor { #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1) }
        static var addButtonUnavailableTextColor: UIColor { #colorLiteral(red: 0.3568627451, green: 0.3529411765, blue: 0.3529411765, alpha: 1) }
        static var borderColor: UIColor { .black.withAlphaComponent(0.08 )}
    }
    
    struct RecentSearchTitle {
        static var titleColor: UIColor { #colorLiteral(red: 0.3568627451, green: 0.3529411765, blue: 0.3529411765, alpha: 1) }
    }
    
    struct RestaurantListCell {
        static var openGreen: UIColor { #colorLiteral(red: 0.1098039216, green: 0.6509803922, blue: 0.3568627451, alpha: 1) }
        static var closedRed: UIColor { #colorLiteral(red: 1, green: 0.1019607843, blue: 0.1019607843, alpha: 1) }
        static var unselectedButtonBg: UIColor { #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1) }
        static var unselectedButtonTextColor: UIColor { #colorLiteral(red: 0.3568627451, green: 0.3529411765, blue: 0.3529411765, alpha: 0.5) }
        static var selectedBgButtonColor: UIColor { #colorLiteral(red: 0.9607843137, green: 0.6980392157, blue: 0.1058823529, alpha: 1) }
        
    }
    
    struct OurStore {
        static var deliveryUnavailable: UIColor { #colorLiteral(red: 0.6901960784, green: 0, blue: 0, alpha: 1) }
        static var deliveryAvailable: UIColor { #colorLiteral(red: 0.1529411765, green: 0.2705882353, blue: 0.5333333333, alpha: 0.8020747103) }
        static var distanceLblColor: UIColor { #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 1) }
        static var timeLblColor: UIColor { #colorLiteral(red: 0.1098039216, green: 0.6509803922, blue: 0.3568627451, alpha: 1) }
    }
    
    struct AllergenView {
        static var collapsed: UIColor { #colorLiteral(red: 0.1990443468, green: 0.3514102101, blue: 0.6041271687, alpha: 0.2) }
        static var expanded: UIColor { #colorLiteral(red: 0.9782040715, green: 0.9782040715, blue: 0.9782039523, alpha: 1) }
    }
    
    struct Customise {
        static var disabledBorderForAdd: UIColor { #colorLiteral(red: 0.4322124422, green: 0.4281697571, blue: 0.4280841947, alpha: 0.5) }
        static var enabledBorderForAdd: UIColor { #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1204728891) }
    }
    
    struct Cart {
        static var outOfStockTextColor: UIColor { #colorLiteral(red: 0.4322124422, green: 0.4281697571, blue: 0.4280841947, alpha: 1) }
        static var couponAppliedColor: UIColor { #colorLiteral(red: 0.3741951585, green: 0.4014635384, blue: 0.4641110301, alpha: 1) }
        static var couponInvalidColor: UIColor { #colorLiteral(red: 0.9215686275, green: 0.4078431373, blue: 0.3803921569, alpha: 1) }
    }
    
    struct Coupon {
        static var applyCouponCodeDisabled: UIColor { #colorLiteral(red: 0.4322124422, green: 0.4281697571, blue: 0.4280841947, alpha: 1) }
        static var couponValidLabel: UIColor { #colorLiteral(red: 0.07984416932, green: 0.6966430545, blue: 0.4318583012, alpha: 1) }
    }
    
    static var offWhiteTableBg: UIColor { #colorLiteral(red: 0.9725490196, green: 0.9843137255, blue: 1, alpha: 1) }
    static var kuduThemeYellow: UIColor { #colorLiteral(red: 0.9732094407, green: 0.7451413274, blue: 0.1295291781, alpha: 1) }
    static var gray636367: UIColor { #colorLiteral(red: 0.3882352941, green: 0.3882352941, blue: 0.4039215686, alpha: 1) }
    static var kuduThemeBlue: UIColor { #colorLiteral(red: 0.1990443468, green: 0.3514102101, blue: 0.6041271687, alpha: 1) }
    static var buttonBorderGrey: UIColor { #colorLiteral(red: 0.6784313725, green: 0.6745098039, blue: 0.6745098039, alpha: 1) }
    static var tabBarUnselectedColor: UIColor { #colorLiteral(red: 0.6642269492, green: 0.6642268896, blue: 0.6642268896, alpha: 1) }
    static var unselectedButtonBg: UIColor { #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1) }
    static var unselectedButtonTextColor: UIColor { #colorLiteral(red: 0.3568627451, green: 0.3529411765, blue: 0.3529411765, alpha: 0.5) }
}
