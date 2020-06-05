//
//  APIRouter.swift
//  AuthLipstick
//
//  Created by Sylvanas on 10/31/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

enum APIRouter: URLRequestConvertible {
    // =========== Begin define api ===========
    //acount
    case login(email: String, password: String)
    case register(email: String,password: String, password_cf:String)
    case updateProfile(email:String, name:String, avatar:String)
    case get_profile
   
    case all_product
    case category
    case skinstype
    case product(category : String)
    case add_product(name:String, barcode:String, preview:[String], sku:String, cate_id:String, cate_name:String, description:String, ext:String, ingredient:String, uses:String, cost:String, skinstype_name:String)
    case add_category(name:String, ext:String)
    case uploadImage(name:String, file:String)
    case update_product(id:Int, name:String, barcode:String, preview:[String], sku:String, cate_id:String, cate_name:String, description:String, ext:String, ingredient:String, uses:String, cost:String, skinstype_name:String)
    case remove_product(id:Int);
    
    // =========== End define api ===========
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login, .register, .add_product, .add_category, .uploadImage, .updateProfile :
            return .post
        case .get_profile, .all_product, .category, .product, .skinstype :
            return .get
        case .update_product :
            return .put
        case .remove_product :
            return .delete
        }
        
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "/api/v1/sign_in"
        case .register:
            return "/api/v1/sign_up"
        case .add_product:
            return "/api/v1/product"
        case .add_category :
            return "/api/v1/category"
        case .get_profile:
            return "/api/v1/my_user"
        case .all_product:
            return "/api/v1/all_product"
        case .category :
            return "/api/v1/category"
        case .skinstype :
            return "/api/v1/skinstype"
        case .product :
            return "/api/v1/product"
        case .updateProfile :
            return "/api/v1/user_update"
        case .uploadImage :
            return "/api/v1/upload"
        case .update_product :
            return "/api/v1/product"
        case .remove_product :
            return "/api/v1/product"
        }
    }
    
    
    // MARK: - Headers
    private var headers: HTTPHeaders {
        //        ,"Access-Control-Allow-Origin":"*"
        var header: HTTPHeaders = ["Content-Type": "application/json"];
            
        
        switch self {
        case .login, .register :
            break
        case .add_product, .add_category, .get_profile, .all_product ,.category, .skinstype , .product, .updateProfile, .uploadImage, .update_product, .remove_product :
            header.add(name: "Authorization", value: getAuthorizationHeader()!)
            break
        }
        return header;
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
            
        case .login(let email,let password) :
            return [
                "email": email,
                "password":password
            ]
        case .register(let email,let password,let password_cf) :
            return [
                "user": [
                    "email": email,
                    "password":password,
                    "password_confirmation":password_cf
                ]
            ]
            
        case .add_product(let name,let barcode,let preview,let sku,let cate_id,let cate_name,let description, let ext, let ingredient,let uses, let cost, let skinstype_name):
            return [
                "item": [
                    "name":name,
                    "barcode":barcode,
                    "previews":preview,
                    "sku":sku,
                    "category_id":cate_id,
                    "category_name":cate_name,
                    "description":description,
                    "ext":ext,
                    "ingredient":ingredient,
                    "uses":uses,
                    "cost":cost,
                    "skinstype_name":skinstype_name
                ]
            ]
        case .update_product(let id, let name, let barcode, let preview, let sku, let cate_id, let cate_name, let description, let ext, let ingredient, let uses, let cost, let skinstype_name) :
            return [
                "id": id,
                "item": [
                    "name":name,
                    "barcode":barcode,
                    "previews":preview,
                    "sku":sku,
                    "category_id":cate_id,
                    "category_name":cate_name,
                    "description":description,
                    "ext":ext,
                    "ingredient":ingredient,
                    "uses":uses,
                    "cost":cost,
                    "skinstype_name":skinstype_name
                ]
            ]
        case .remove_product(let id) :
            return [
                "id": id
            ]
        case .add_category(let name, let ext) :
            return [
                "category":[
                    "name":name,
                    "ext":ext
                ]
            ]
        case .get_profile :
            return[:]
        case .all_product :
            return [:]
        case .category :
            return[:]
        case .skinstype :
            return[:]
        case .product(let category):
            return [
                "category":category
            ]
        case .updateProfile(let email,let name,let avatar) :
            return [
                "user": [
                    "avatar": avatar,
                    "email": email,
                    "name": name
                ]
            ]
        case .uploadImage(let name, let file) :
            return [
                       "uploads": [
                           "name": name,
                           "file": file
                       ]
                   ]
        }
    }
    
    // MARK: - URL request
    func asURLRequest() throws -> URLRequest {
//        let url = try
        // setting path
        let URLString = try! URL(string: "\(Config.BASE_URL)\(path)")!.asURL()
        print(URLString)
      
        var urlRequest: URLRequest = URLRequest(url: URLString)
        
        // setting method
        urlRequest.httpMethod = method.rawValue
        
        
        // setting header
        
        urlRequest.headers = headers;
//        for (key, value) in headers {
//            urlRequest.addValue(value, forHTTPHeaderField: key)
//        }
        if let parameters = parameters {
            do {
                
                if  (method.rawValue == "GET") || (method.rawValue == "DELETE")
                {
                    
                    urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
                    
                } else {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                }
                
                
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        return urlRequest
    }
    
    private func getAuthorizationHeader() -> String? {
        let token = "Bearer \(Globalvariables.shareInstance.token_auth)"
        
        return token
    }
    
   private  func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
