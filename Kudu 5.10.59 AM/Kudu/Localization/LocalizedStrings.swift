//
//  LS.swift
//  Kudu
//
//  Created by Admin on 11/05/22.
//

import Foundation
import UIKit

extension String {
    func getLocalized() -> String {
        let selected = AppUserDefaults.selectedLanguage().rawValue
        let key = self
        return NSLocalizedString(key, tableName: nil, bundle: Bundle(path: Bundle.main.path(forResource: selected, ofType: "lproj")!)!, value: "", comment: "")
    }
}

final class LocalizedStrings {
    
    struct Login {
        static var login: String {"login".getLocalized()}
        static var pleaseEnterYourPhoneNumber: String {
            "pleaseEnterYourPhoneNumber".getLocalized() }
        static var enterYourPhoneNumber: String { "enterYourPhoneNumber".getLocalized() }
        static var phoneNo: String { "phoneNo".getLocalized() }
        static var getOtp: String {"getOtp".getLocalized()}
        static var orContinueWith: String {"orContinueWith".getLocalized()}
        static var phoneNotRegistered: String { "phoneNotRegistered".getLocalized() }
        static var dontHaveAnAccount: String { "dontHaveAnAccount".getLocalized() }
        static var signUp: String { "signUp".getLocalized() }
        static var loginToUnlockAwesomeFeatures: String { "loginToUnlockAwesomeFeatures".getLocalized() }
    }
    
    struct SignUp {
        static var createAccountSignUpLbl: String { "createAccountSignUpLbl".getLocalized() }
        static var enterYourName: String { "enterYourName".getLocalized() }
        static var enterYourEmailOptional: String { "enterYourEmailOptional".getLocalized()}
        static var enterYourPhoneNumber: String { "enterYourPhoneNumber".getLocalized() }
        static var signUp: String { "signUp".getLocalized() }
        static var alreadyHaveAnAccount: String { "alreadyHaveAnAccount".getLocalized() }
        static var signIn: String {"signIn".getLocalized()}
        static var continueText: String { "continue".getLocalized() }
        static var cancel: String {"cancel".getLocalized()}
        static var pleaseEnterFullName: String { "pleaseEnterFullName".getLocalized() }
        static var pleaseEnterValidFullName: String { "pleaseEnterValidFullName".getLocalized() }
        static var pleaseEnterPhoneNumber: String { "pleaseEnterPhoneNumber".getLocalized() }
        static var pleaseEnterValidPhoneNumber: String { "pleaseEnterValidPhoneNumber".getLocalized() }
        static var pleaseEnterValidEmail: String { "pleaseEnterValidEmail".getLocalized() }
        static var socialAccountNothWitUs: String { "socialAccountNotWithUs".getLocalized() }
        static var bySigningUpYouAgree: String { "bySigningUpYouAgree".getLocalized() }
        static var setupTermsAndConditionsViewtermsOfUse: String { "setupTermsAndConditionsViewtermsOfUse".getLocalized() }
        static var setupTermsAndConditionsViewAndText: String { "setupTermsAndConditionsViewAndText".getLocalized() }
        static var setupTermsAndConditionsViewPrivacyPolicy: String { "setupTermsAndConditionsViewPrivacyPolicy".getLocalized()}
    }
    
    struct PhoneVerification {
        static var verifyPhoneNumber: String { "verifyPhoneNumber".getLocalized() }
        static var pleaseEnterTheOtpCodeSentTo: String { "pleaseEnterTheOtpCodeSentTo".getLocalized() }
        static var differentNumber: String { "differentNumber".getLocalized() }
        static var didntReceiveTheOTPCode: String { "didntReceiveTheOTPCode".getLocalized() }
        static var resendCode: String { "resendCode".getLocalized() }
        static var verify: String { "verify".getLocalized() }
        static var youHaveXNumberAttemptsRemaining: String { "youHaveXNumberAttemptsRemaining".getLocalized() }
        static var youHaveXNumberAttemptRemaining: String { "youHaveXNumberAttemptsRemaining".getLocalized() }
        static var verifyEmailAddress: String { "verifyEmailAddressTitle".getLocalized() }
        static var differentEmail: String { "differentEmail".getLocalized() }
    }
    
    struct Home {
        static var deliverTo: String {"deliverTo".getLocalized()}
        static var delivery: String {"delivery".getLocalized()}
        static var curbside: String {"curbside".getLocalized()}
        static var pickup: String {"pickup".getLocalized()}
        static var exploreMenu: String {"exploreMenu".getLocalized()}
        static var fullMenu: String { "fullMenu".getLocalized() }
        static var recommendations: String { "recommendations".getLocalized() }
        static var viewAll: String { "viewAll".getLocalized() }
        static var favourites: String { "favourites".getLocalized() }
        static var orderFromListOfFavourites: String { "orderFromListOfFavourites".getLocalized() }
        static var orderNow: String { "orderNow".getLocalized() }
        static var pickupFrom: String { "pickupFrom".getLocalized() }
        static var unableToFetchAddress: String {"unableToFetchAddress".getLocalized()}
        static var setDeliveryLocation: String {"setDeliveryLocation".getLocalized()}
        static var setCurbsideLocation: String {"setCurbsideLocation".getLocalized()}
        static var setPickupLocation: String { "setPickUpLocation".getLocalized() }
        static var cancel: String {"cancel".getLocalized()}
        static var setting: String {"setting".getLocalized()}
        static var inStorePromos: String { "inStorePromos".getLocalized() }
    }
    
    struct Profile {
        static var edit: String { "edit".getLocalized() }
        static var myAccount: String { "myAccount".getLocalized() }
        static var orders: String { "orders".getLocalized() }
        static var payments: String { "payments".getLocalized() }
        static var favouritesProfile: String { "favouritesProfile".getLocalized() }
        static var address: String { "address".getLocalized() }
        static var ourStore: String { "ourStore".getLocalized() }
        static var controlCentre: String { "controlCentre".getLocalized() }
        static var menu: String { "menu".getLocalized() }
        static var notificationPref: String { "notificationPref".getLocalized() }
        static var language: String { "language".getLocalized() }
        static var verifyNow: String { "verifyNow".getLocalized() }
    }
    
    struct ExploreMenu {
        static var exploreMenuTitle: String { "exploreMenuTitle".getLocalized() }
        static var addButton: String { "addButton".getLocalized() }
        static var customizable: String { "customizable".getLocalized() }
        static var moreLabel: String { "moreLabel".getLocalized() }
    }
    
    struct SearchMenu {
        static var searchByNameOrCategories: String { "searchByNameOrCategories".getLocalized() }
        static var topSearchedCategories: String { "topSearchedCategories".getLocalized() }
        static var recentSearchesTitle: String { "recentSearchesTitle".getLocalized() }
        static var inDish: String { "inDish".getLocalized() }
        static var inCategory: String { "inCategory".getLocalized() }
    }
    
    struct MyAddress {
        static var myAddressLabel: String {"myAddressLabel".getLocalized()}
        static var defaultAddressTitle: String {"defaultAddressTitle".getLocalized()}
        static var otherAddressTitle: String {"otherAddressTitle".getLocalized()}
        static var addNewAddressBtn: String {"addNewAddressBtn".getLocalized()}
        static var delete: String {"delete".getLocalized()}
        static var edit: String { "edit".getLocalized() }
        static var editAddress: String { "editAddress".getLocalized() }
        static var somethingWentWrong: String {"somethingWentWrong".getLocalized()}
        static var cancel: String {"cancel".getLocalized()}
        static var add: String {"add".getLocalized()}
        static var showDeletePopUpMessage: String {"showDeletePopUpMessage".getLocalized()}
        static var showAddDefaultAddressPopUpMessage: String {"showAddDefaultAddressPopUpMessage".getLocalized()}
        static var addressAddedMessage: String { "addressAddedMessage".getLocalized() }
        static var addressUpdatedMessage: String { "addressUpdatedMessage".getLocalized() }
        static var addressAddedTitle: String { "addressAddedTitle".getLocalized() }
        static var addressUpdatedTitle: String { "addressUpdatedTitle".getLocalized() }
        
    }
    
    struct AddNewAddress {
        static var saveButton: String {"saveButton".getLocalized()}
        static var enterYourName: String {"enterYourName".getLocalized()}
        static var enterMobileNumberOptional: String { "enterMobileNumberOptional".getLocalized() }
        static var buildingName: String { "buildingName".getLocalized() }
        static var city: String { "city".getLocalized() }
        static var state: String { "state".getLocalized() }
        static var landmark: String { "landmark".getLocalized() }
        static var zipCode: String { "zipCode".getLocalized() }
        static var searchLocation: String { "searchLocation".getLocalized() }
        static var home: String { "home".getLocalized() }
        static var work: String { "work".getLocalized() }
        static var other: String { "other".getLocalized() }
        static var setAsDefaultAddress: String { "setAsDefaultAddress".getLocalized()}
        static var pleaseEnterName: String {"pleaseEnterName".getLocalized()}
        static var pleaseAddLocation: String {"pleaseAddLocation".getLocalized()}
        static var pleaseEnterState: String {"pleaseEnterState".getLocalized()}
        static var pleaseEnterCity: String {"pleaseEnterCity".getLocalized()}
        static var pleaseEnterZipcode: String {"pleaseEnterZipcode".getLocalized()}
        static var pleaseEnterBuildingName: String {"pleaseEnterBuildingName".getLocalized()}
        static var pleaseEnterAddressLabel: String {"pleaseEnterAddressLabel".getLocalized()}
    }
    
    struct Setting {
        static var settings: String { "settings".getLocalized() }
        static var help: String {"help".getLocalized()}
        static var faq: String {"faq".getLocalized()}
        static var support: String {"support".getLocalized()}
        static var sendFeedback: String {"sendFeedback".getLocalized()}
        static var content: String {"content".getLocalized()}
        static var privacyAndPolicy: String {"privacyAndPolicy".getLocalized()}
        static var termsAndConditions: String {"termsAndConditions".getLocalized()}
        static var ourVision: String {"ourVision".getLocalized()}
        static var aboutUs: String {"aboutUs".getLocalized()}
        static var accountControl: String {"accountControl".getLocalized()}
        static var deleteAccount: String {"deleteAccount".getLocalized()}
        static var logOut: String {"logOut".getLocalized()}
        static var cancel: String {"cancel".getLocalized()}
        static var logoutButton: String { "logoutButton".getLocalized() }
        static var areYouSureYouWantToLogout: String {"areYouSureYouWantToLogout".getLocalized()}
        static var confirm: String {"confirm".getLocalized()}
        static var yourInformationWillBeErasedAsAResult: String {"yourInformationWillBeErasedAsAResult".getLocalized()}
        static var itLooksLikeYouAreExperiencingProblems: String { "itLooksLikeYouAreExperiencingProblems".getLocalized() }
        static var callUs: String { "callUs".getLocalized() }
        static var emailUs: String { "emailUs".getLocalized() }
        static var pleasewaitWhileUploading: String {"pleasewaitWhileUploading".getLocalized()}
        static var pleaseEnterYourName: String {"pleaseEnterYourName".getLocalized()}
        static var pleaseEnterValidName: String {"pleaseEnterValidName".getLocalized()}
        static var pleaseEnterYourMobileNumber: String {"pleaseEnterYourMobileNumber".getLocalized()}
        static var pleaseEnterValidNumber: String {"pleaseEnterValidNumber".getLocalized()}
        static var pleaseEnterYourFeedback: String {"pleaseEnterYourFeedback".getLocalized()}
        static var pleaseEnterValidFeedback: String {"pleaseEnterValidFeedback".getLocalized()}
        static var pleaseEnterValidEmailId: String {"pleaseEnterValidEmailId".getLocalized()}
        static var feedbackSentSuccessfully: String {"feedbackSentSuccessfully".getLocalized()}
        static var enterMobileNumber: String {"enterMobileNumber".getLocalized()}
        static var writeYourFeedbackHere: String {"writeYourFeedbackHere".getLocalized()}
        static var enterYourName: String {"enterYourName".getLocalized()}
        static var emailIdOptional: String {"emailIdOptional".getLocalized()}
        static var submit: String { "submit".getLocalized() }
        static var uploadPhoto: String { "uploadPhoto".getLocalized() }
        static var attachedPhotos: String { "attachedPhotos".getLocalized() }
    }
    
    struct GoogleAutoComplete {
        static var recentSearches: String { "recentSearches".getLocalized() }
        static var savedAddresses: String { "savedAddresses".getLocalized() }
        static var typeAddressToSearch: String { "typeAddressToSearch".getLocalized() }
        static var searchYourLocation: String { "searchYourLocation".getLocalized() }
        static var setLocationTitle: String {"setLocationTitle".getLocalized()}
        static var setDeliveryLocation: String {"setDeliveryLocation".getLocalized()}
        static var cancel: String {"cancel".getLocalized()}
        static var settings: String { "settings".getLocalized() }
        static var somethingWentWrong: String {"somethingWentWrong".getLocalized()}
    }
    
    struct MapPin {
        static var setLocationTitle: String {"setLocationTitle".getLocalized()}
        static var unableToFetchAddress: String {"unableToFetchAddress".getLocalized()}
        static var confirmLocation: String { "confirmLocation".getLocalized() }
        static var clear: String {"clear".getLocalized()}
        static var movePinLabel: String { "movePinLabel".getLocalized() }
    }
    
    struct SetRestaurant {
        static var selectBranch: String { "selectBranch".getLocalized() }
        static var setCurbsideLocation: String {"setCurbsideLocation".getLocalized()}
        static var setPickupLocation: String { "setPickUpLocation".getLocalized() }
        static var cancel: String {"cancel".getLocalized()}
        static var settings: String { "settings".getLocalized() }
        static var open: String { "open".getLocalized() }
        static var closed: String { "closed".getLocalized() }
        static var xStoreNearYou: String { "xStoreNearYou".getLocalized() }
        static var map: String { "map".getLocalized() }
        static var km: String { "km".getLocalized() }
        static var confirmlocationSmall: String { "confirmlocationSmall".getLocalized() }
        static var list: String { "list".getLocalized() }
        static var xKuduNearYou: String { "xKuduNearYou".getLocalized() }
        static var amString: String { "amString".getLocalized() }
        static var pmString: String { "pmString".getLocalized() }
    }
    
    struct NoInternetConnection {
        static var somethingWentWrong: String {"somethingWentWrong".getLocalized()}
        static var pleaseCheckYourInternetconnection: String {"pleaseCheckYourInternetconnection".getLocalized()}
        static var tryAgain: String {"tryAgain".getLocalized()}
    }
    
    struct NotificationPref {
        static var pushNotifications: String { "pushNotifications".getLocalized() }
        static var muteNotification: String { "muteNotification".getLocalized() }
        static var loyaltyProgram: String { "loyaltyProgram".getLocalized() }
        static var orderPurchase: String { "orderPurchase".getLocalized() }
        static var promosOffers: String { "promosOffers".getLocalized() }
        static var pushNotificationsSubtitle: String { "pushNotificationsSubtitle".getLocalized() }
        static var muteNotificationSubtitle: String { "muteNotificationSubtitle".getLocalized() }
        static var loyaltyProgramSubtitle: String { "loyaltyProgramSubtitle".getLocalized() }
        static var orderPurchaseSubtitle: String { "orderPurchaseSubtitle".getLocalized() }
        static var promosOffersSubtitle: String { "promosOffersSubtitle".getLocalized() }
    }
    
    struct EditProfile {
        static var editProfile: String { "editProfile".getLocalized() }
        static var enterYourEmail: String { "enterYourEmail".getLocalized() }
        static var pleaseEnterEmail: String { "pleaseEnterEmail".getLocalized() }
        static var emailAlreadyVerified: String { "emailAlreadyVerified".getLocalized() }
        static var emailAlreadyAssociated: String { "emailAlreadyAssociated".getLocalized() }
        static var cancel: String { "cancel".getLocalized() }
        static var updateButton: String { "updateButton".getLocalized() }
    }
    
    struct BrowseMenu {
        static var browseMenu: String { "browseMenu".getLocalized() }
    }

    struct OurStore {
        static var DeliveryAvailable: String {"DeliveryAvailable".getLocalized()}
        static var DeliveryUnavailable: String {"DeliveryUnavailable".getLocalized()}
    }
}
