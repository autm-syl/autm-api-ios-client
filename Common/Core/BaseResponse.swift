//
//  BaseResponse.swift
//  AuthLipstick
//
//  Created by Sylvanas on 10/31/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import ObjectMapper
class BaseResponse<T: Mappable>: Mappable {
    var targetUrl : String?
    var code: Int?
    var error: String?
    var success : Bool?
    var unAuthorizedRequest : Bool?
    var result: [T]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        code <- map["code"]
        error <- map["error"]
        success <- map["success"]
        unAuthorizedRequest <- map["unAuthorizedRequest"]
        result <- map["result"]
    }
    
    func isSuccessCode() -> Bool? {
        return success == true
    }
}


class BaseObjectResponse<T: Mappable>: Mappable {
    var targetUrl : String?
    var code: Int?
    var error: String?
    var success : Bool?
    var unAuthorizedRequest : Bool?
    var result: T?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        code <- map["code"]
        error <- map["error"]
        success <- map["success"]
        unAuthorizedRequest <- map["unAuthorizedRequest"]
        result <- map["result"]
    }
    
    func isSuccessCode() -> Bool? {
        return success == true
    }
}
class BaseIntResponse: Mappable {
    var targetUrl : String?
    var code: Int?
    var error: String?
    var success : Bool?
    var unAuthorizedRequest : Bool?
    var result: Int?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        code <- map["code"]
        error <- map["error"]
        success <- map["success"]
        unAuthorizedRequest <- map["unAuthorizedRequest"]
        result <- map["result"]
    }
    
    func isSuccessCode() -> Bool? {
        return success == true
    }
}


class BaseResponseError {
    var mErrorType: NetworkErrorType!
    var mErrorCode: Int!
    var mErrorMessage: String!
    required init?(map: Map) {
        
    }
    
    init(_ errorType: NetworkErrorType,_ errorCode: Int,_ errorMessage: String) {
        mErrorType = errorType
        mErrorCode = errorCode
        mErrorMessage = errorMessage
    }
    
    
}
