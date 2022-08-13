//
//  TwitterService.swift
//  Kudu
//
//  Created by Admin on 23/05/22.
//

import Foundation
import CommonCrypto

protocol TwitterServiceDelegate: AnyObject {
    func loadAuthURL(url: URL)
    func credentialsReceived(userId: String, screenName: String)
}

class TwitterService {
    
    private var credential: RequestAccessTokenResponse?
    private var callbackObserver: NSObjectProtocol?
    private var authUrl: URL?
    
    weak var delegate: TwitterServiceDelegate?
    
    func authorizationHeader(params: [String: Any]) -> String {
      var parts: [String] = []
      for param in params {
        let key = param.key.urlEncoded
        let val = "\(param.value)".urlEncoded
        parts.append("\(key)=\"\(val)\"")
      }
      return "OAuth " + parts.sorted().joined(separator: ", ")
    }
    
    func signatureKey(_ consumerSecret: String, _ oauthTokenSecret: String?) -> String {
      
        guard let oauthSecret = oauthTokenSecret?.urlEncoded
              else { return consumerSecret.urlEncoded+"&" }
      
        return consumerSecret.urlEncoded+"&"+oauthSecret
      
    }
    
    func signatureParameterString(params: [String: Any]) -> String {
      var result: [String] = []
      for param in params {
        let key = param.key.urlEncoded
        let val = "\(param.value)".urlEncoded
        result.append("\(key)=\(val)")
      }
      return result.sorted().joined(separator: "&")
    }
    
    func signatureBaseString(_ httpMethod: String = "POST", _ url: String,
                             _ params: [String: Any]) -> String {
      
      let parameterString = signatureParameterString(params: params)
      return httpMethod + "&" + url.urlEncoded + "&" + parameterString.urlEncoded
      
    }
    
    func hmac_sha1(signingKey: String, signatureBase: String) -> String {
      // HMAC-SHA1 hashing algorithm returned as a base64 encoded string
      var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
      CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, signatureBase, signatureBase.count, &digest)
      let data = Data(digest)
      return data.base64EncodedString()
    }
    
    func oauthSignature(httpMethod: String = "POST", url: String,
                        params: [String: Any], consumerSecret: String,
                        oauthTokenSecret: String? = nil) -> String {
      
      let signingKey = signatureKey(consumerSecret, oauthTokenSecret)
      let signatureBase = signatureBaseString(httpMethod, url, params)
      return hmac_sha1(signingKey: signingKey, signatureBase: signatureBase)
      
    }
    
    struct RequestOAuthTokenInput {
      let consumerKey: String
      let consumerSecret: String
      let callbackScheme: String
    }
    struct RequestOAuthTokenResponse {
      let oauthToken: String
      let oauthTokenSecret: String
      let oauthCallbackConfirmed: String
    }
    struct RequestAccessTokenInput {
      let consumerKey: String
      let consumerSecret: String
      let requestToken: String // = RequestOAuthTokenResponse.oauthToken
      let requestTokenSecret: String // = RequestOAuthTokenResponse.oauthTokenSecret
      let oauthVerifier: String
    }
    struct RequestAccessTokenResponse {
      let accessToken: String
      let accessTokenSecret: String
      let userId: String
      let screenName: String
    }
    
    func requestOAuthToken(args: RequestOAuthTokenInput, _ complete: @escaping (RequestOAuthTokenResponse) -> Void) {
      
      let request = (url: "https://api.twitter.com/oauth/request_token", httpMethod: "POST")
      let callback = args.callbackScheme + "://"
      
      var params: [String: Any] = [
        "oauth_callback": callback,
        "oauth_consumer_key": args.consumerKey,
        "oauth_nonce": UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": String(Int(NSDate().timeIntervalSince1970)),
        "oauth_version": "1.0"
      ]
      // Build the OAuth Signature from Parameters
      params["oauth_signature"] = oauthSignature(httpMethod: request.httpMethod, url: request.url,
                                                 params: params, consumerSecret: args.consumerSecret)
      
      // Once OAuth Signature is included in our parameters, build the authorization header
      let authHeader = authorizationHeader(params: params)
      
      guard let url = URL(string: request.url) else { return }
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = request.httpMethod
      urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
      let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
        guard let data = data else { return }
        guard let dataString = String(data: data, encoding: .utf8) else { return }
        // dataString should return: oauth_token=XXXX&oauth_token_secret=YYYY&oauth_callback_confirmed=true
        let attributes = dataString.urlQueryStringParameters
        let result = RequestOAuthTokenResponse(oauthToken: attributes["oauth_token"] ?? "",
                                               oauthTokenSecret: attributes["oauth_token_secret"] ?? "",
                                               oauthCallbackConfirmed: attributes["oauth_callback_confirmed"] ?? "")
        complete(result)
      }
      task.resume()
    }
    
    func requestAccessToken(args: RequestAccessTokenInput,
                            _ complete: @escaping (RequestAccessTokenResponse) -> Void) {
      
      let request = (url: "https://api.twitter.com/oauth/access_token", httpMethod: "POST")
      
      var params: [String: Any] = [
        "oauth_token": args.requestToken,
        "oauth_verifier": args.oauthVerifier,
        "oauth_consumer_key": args.consumerKey,
        "oauth_nonce": UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
        "oauth_signature_method": "HMAC-SHA1",
        "oauth_timestamp": String(Int(NSDate().timeIntervalSince1970)),
        "oauth_version": "1.0"
      ]
      
      // Build the OAuth Signature from Parameters
      params["oauth_signature"] = oauthSignature(httpMethod: request.httpMethod, url: request.url,
                                                 params: params, consumerSecret: args.consumerSecret,
                                                 oauthTokenSecret: args.requestTokenSecret)
      
      // Once OAuth Signature is included in our parameters, build the authorization header
      let authHeader = authorizationHeader(params: params)
      
      guard let url = URL(string: request.url) else { return }
      var urlRequest = URLRequest(url: url)
      urlRequest.httpMethod = request.httpMethod
      urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
      let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
        guard let data = data else { return }
        guard let dataString = String(data: data, encoding: .utf8) else { return }
        let attributes = dataString.urlQueryStringParameters
        let result = RequestAccessTokenResponse(accessToken: attributes["oauth_token"] ?? "",
                                                accessTokenSecret: attributes["oauth_token_secret"] ?? "",
                                                userId: attributes["user_id"] ?? "",
                                                screenName: attributes["screen_name"] ?? "")
        complete(result)
      }
      task.resume()
    }
    
    func requestEmail(args: RequestAccessTokenInput, accessToken: String, accessTokenSecret: String, screenName: String,
                      _ complete: @escaping ([String: String]) -> Void) {
        //https://api.twitter.com/1.1/account/verify_credentials.json
        let request = (url: "https://api.twitter.com/1.1/account/verify_credentials.json", httpMethod: "GET")
        //let request = (url: "https://api.twitter.com/1.1/users/profile_banner.json", httpMethod: "GET")
        var params: [String: Any] = [
          "oauth_token": accessToken,
          "oauth_consumer_key": args.consumerKey,
          "oauth_nonce": UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
          "oauth_signature_method": "HMAC-SHA1",
          "oauth_timestamp": String(Int(NSDate().timeIntervalSince1970)),
          "oauth_version": "1.0"
        ]
        //?include_email=true
        params["oauth_signature"] = oauthSignature(httpMethod: request.httpMethod, url: request.url,
                                                   params: params, consumerSecret: args.consumerSecret,
                                                   oauthTokenSecret: accessTokenSecret)
        // Once OAuth Signature is included in our parameters, build the authorization header
        let authHeader = authorizationHeader(params: params)
        
        //guard let url = URL(string: request.url) else { return }
        guard var modifiedURLComponents = URLComponents(string: request.url) else { return }
        //modifiedURLComponents.queryItems = [URLQueryItem(name: "include_email", value: "true"), URLQueryItem(name: "include_entities", value: "false"), URLQueryItem(name: "skip_status", value: "true"), URLQueryItem(name: "screen_name", value: screenName)]
        //include_entities' => 'false', 'skip_status' => 'true
        modifiedURLComponents.percentEncodedQuery = modifiedURLComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var urlRequest = URLRequest(url: modifiedURLComponents.url!)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
          guard let data = data else { return }
          guard let dataString = String(data: data, encoding: .utf8) else { return }
          debugPrint(dataString)
        let attributes = dataString.urlQueryStringParameters
          complete(attributes)
        }
        task.resume()
        //String(data: data!, encoding: .utf8)
    }
    
//    func invalidatePreviousToken(_ complete: @escaping ([String: String]) -> Void) {
//        //https://api.twitter.com/1.1/account/verify_credentials.json
//        guard let accessTokenResponse = DataManager.shared.twitterAccessTokenResponse else {
//
//            complete([:])
//
//            return }
//        let request = (url: "https://api.twitter.com/1.1/oauth/invalidate_token.json", httpMethod: "POST")
//        var params: [String: Any] = [
//            "oauth_token": accessTokenResponse.accessToken ,
//            "oauth_consumer_key": Constants.TwitterCredentials.apiKey,
//          "oauth_nonce": UUID().uuidString, // nonce can be any 32-bit string made up of random ASCII values
//          "oauth_signature_method": "HMAC-SHA1",
//          "oauth_timestamp": String(Int(NSDate().timeIntervalSince1970)),
//          "oauth_version": "1.0"
//        ]
//        //?include_email=true
//        params["oauth_signature"] = oauthSignature(httpMethod: request.httpMethod, url: request.url,
//                                                   params: params, consumerSecret: Constants.TwitterCredentials.apiKeySecret,
//                                                   oauthTokenSecret: accessTokenResponse.accessTokenSecret)
//        // Once OAuth Signature is included in our parameters, build the authorization header
//        let authHeader = authorizationHeader(params: params)
//
//        //guard let url = URL(string: request.url) else { return }
//        guard var modifiedURLComponents = URLComponents(string: request.url) else { return }
//        //modifiedURLComponents.queryItems = [URLQueryItem(name: "include_email", value: "true"), URLQueryItem(name: "include_entities", value: "false"), URLQueryItem(name: "skip_status", value: "true"), URLQueryItem(name: "screen_name", value: screenName)]
//        //include_entities' => 'false', 'skip_status' => 'true
//        modifiedURLComponents.percentEncodedQuery = modifiedURLComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
//        var urlRequest = URLRequest(url: modifiedURLComponents.url!)
//        urlRequest.httpMethod = request.httpMethod
//        urlRequest.setValue(authHeader, forHTTPHeaderField: "Authorization")
//        let task = URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
//          guard let data = data else { return }
//          guard let dataString = String(data: data, encoding: .utf8) else { return }
//          debugPrint(dataString)
//        let attributes = dataString.urlQueryStringParameters
//          complete(attributes)
//        }
//        task.resume()
//        //String(data: data!, encoding: .utf8)
//    }
    
    func authorize() {
      //self.showSheet = true // opens the sheet containing our safari view
        debugPrint("Authorized called")
      // Start Step 1: Requesting an access token
        let oAuthTokenInput = RequestOAuthTokenInput(consumerKey: Constants.TwitterCredentials.apiKey,
                                                     consumerSecret: Constants.TwitterCredentials.apiKeySecret,
                                                     callbackScheme: Constants.TwitterCredentials.scheme)
        requestOAuthToken(args: oAuthTokenInput) { oAuthTokenResponse in
        // Kick off our Step 2 observer: start listening for user login callback in scene delegate (from handleOpenUrl)
          self.callbackObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.init(rawValue: Constants.NotificationObservers.twitterCallBack.rawValue), object: nil, queue: .main) { notification in
          // remove notification observer
          if self.callbackObserver == nil { return }
          debugPrint("VERIFICATION BEGAN")
          self.callbackObserver = nil
          guard let url = notification.object as? URL else { return }
          guard let parameters = url.query?.urlQueryStringParameters else { return }
          /*
          url => twittersdk://success?oauth_token=XXXX&oauth_verifier=ZZZZ
          url.query => oauth_token=XXXX&oauth_verifier=ZZZZ
          url.query?.urlQueryStringParameters => ["oauth_token": "XXXX", "oauth_verifier": "YYYY"]
          */
          guard let verifier = parameters["oauth_verifier"] else { return }
          // Start Step 3: Request Access Token
          let accessTokenInput = RequestAccessTokenInput(consumerKey: Constants.TwitterCredentials.apiKey,
                                                         consumerSecret: Constants.TwitterCredentials.apiKeySecret,
                                                         requestToken: oAuthTokenResponse.oauthToken,
                                                         requestTokenSecret: oAuthTokenResponse.oauthTokenSecret,
                                                         oauthVerifier: verifier)
          self.requestAccessToken(args: accessTokenInput) { accessTokenResponse in
            // Process Completed Successfully!
            DispatchQueue.main.async {
              self.credential = accessTokenResponse
                debugPrint("Logged in with social id : \(accessTokenResponse.userId) and name : \(accessTokenResponse.screenName)")
              self.delegate?.credentialsReceived(userId: accessTokenResponse.userId, screenName: accessTokenResponse.screenName)
              self.authUrl = nil
            }
          }
        }
                                                
        // Start Step 2: User Twitter Login
        let urlString = "https://api.twitter.com/oauth/authorize?oauth_token=\(oAuthTokenResponse.oauthToken)&force_login=true"
          debugPrint("oauth token :\(oAuthTokenResponse.oauthToken)")
        guard let oauthUrl = URL(string: urlString) else { return }
        DispatchQueue.main.async {
          self.authUrl = oauthUrl // sets our safari view url
            self.delegate?.loadAuthURL(url: oauthUrl)
        }
      }
    }
}
