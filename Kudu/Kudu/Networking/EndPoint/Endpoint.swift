import Foundation
import Alamofire

enum SocialLoginType: String {
    case facebook
    case google
    case apple
    case twitter
}

enum Endpoint {
    // MARK: PRELOGIN END POINTS
    case login(mobileNo: String, countryCode: String)
    case sendOtp(mobileNo: String, countryCode: String = "966", email: String?)
    case signUp(fullName: String, email: String?, mobileNo: String, countryCode: String = "966", deviceId: String = "123", deviceToken: String = "321")
    case verifyMobileOtp(fullName: String?, email: String?, mobileNo: String, countryCode: String = "966", mobileOtp: String, deviceId: String = "123", deviceToken: String = "321")
    case socialLogIn(socialLoginType: SocialLoginType, socialId: String, deviceId: String = "123", deviceToken: String = "321")
    case socialSignup(socialLoginType: SocialLoginType, socialId: String, fullName: String, mobileNo: String, email: String?, countryCode: String = "966", deviceId: String = "123", deviceToken: String = "321")
    case socialVerification(socialLoginType: SocialLoginType, socialId: String, fullName: String, mobileNo: String, email: String?, mobileOtp: String, countryCode: String = "966", deviceId: String = "123", deviceToken: String = "321")
    
    // MARK: ADDRESS END POINTS
    case addAddress(request: AddAddressRequest)
    case editAddress(addressId: String, request: AddAddressRequest)
    case getAddressList
    case deleteAddress(id: String)
    
    // MARK: SETTINGS END POINTS
    case sendFeedback(request: SendFeedbackRequest)
    case supportDetails
    case logout
    case deleteAccount
    case changePhoneNumber(req: ChangePhoneNumberRequest)
    
    // MARK: HOME END POINTS
    case menuList(request: MenuListRequest)
    case banners(serviceType: APIEndPoints.ServicesType)
    case menuItemList(menuId: String)
    case itemDetail(itemId: String)
    case getRestaurantSuggestions(request: RestaurantListRequest)
    case getRestaurantListing(request: RestaurantListRequest)
    case topSearchMenu(servicesType: APIEndPoints.ServicesType)
    case getSearchSuggestionsMenu(searchKey: String, type: APIEndPoints.ServicesType, storeId: String?)
    case getSearchResults(storeId: String?, pageNo: Int, limit: Int = 10, type: APIEndPoints.ServicesType, searchKey: String)
    case editProfile(name: String?, email: String?)
    case verifyEmailOtp(otp: String, email: String)
    case sendOtpOnMail(email: String)
    case ourStoreListing(searchKey: String, lat: Double, long: Double)
    case addFavourites(req: FavouriteRequest)
    case favouriteItemList(pageNo: Int, limit: Int)
    case favouriteHashSync
    case getStoreIdForDelivery(lat: Double, long: Double, serviceType: APIEndPoints.ServicesType)
    case getRecommendations(serviceType: APIEndPoints.ServicesType)
    
    // MARK: NOTIFICATION END POINTS
    case notificationPref(req: NotificationPrefRequest)
    
    // MARK: CART END POINTS
    case addItemToCart(req: AddCartItemRequest)
    case updateCartQuantity(req: UpdateCartCountRequest)
    case removeItemFromCart(req: RemoveItemFromCartRequest)
    case syncCart(storeId: String?)
    case getCartConfig(storeId: String?)
    case cancellationPolicy
    case youMayAlsoLike(serviceType: APIEndPoints.ServicesType)
    case clearCart
    case updateVehicle(req: VehicleUpdateRequest)
    
    // MARK: COUPON END POINTS
    case getOnlineCouponListing(serviceType: APIEndPoints.ServicesType)
    case updateCouponOnCart(apply: Bool, couponId: String)
    case getCouponDetail(id: String)
    case getCouponCodeDetail(couponCode: String)
    case selectedRestaurantList(exclude: [String], pageNo: Int, limit: Int = 10, searchKey: String?)
    case inStoreCouponList(storeId: String?)
    case inStoreCouponDetails(id: String)
    case redeemInStoreCoupon(couponId: String, promoId: String, couponCode: String)
    
    // MARK: ORDER END POINTS
    case placeOrder(req: OrderPlaceRequest)
    case orderList(pageNo: Int, limit: Int = 10)
    case orderDetails(orderId: String)
    case arrivedAtStore(orderId: String)
    case cancelOrder(orderId: String)
    case rating(req: RatingRequestModel)
    case reorderItems(orderId: String)
    case validateOrder(req: OrderPlaceRequest)

    // MARK: Notification
    case notificationList(pageNo: Int, limit: Int)
    case deleteNotification(id: String)
    case deleteAllNotification
    
    // MARK: PAYMENT END POINTS
    case payment(cardToken: String)
    case tokenCardPayment(req: AddCardPaymentRequest, isApplePay: Bool)
    case savedCardPayment(orderId: String, cardId: String, cvv: String, amount: Double)
    case codPayment(orderId: String, amount: Double)
    case getCards
    case deleteCard(cardId: String)
    case changeDeviceLang(language: String)
}
