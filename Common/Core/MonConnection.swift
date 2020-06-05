//
//  MonConnection.swift
//  AuthLipstick
//
//  Created by Sylvanas on 10/31/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftyJSON
import SVProgressHUD;

class MonConnection {
     
       static func isConnectedToInternet() ->Bool {
           return NetworkReachabilityManager()!.isReachable
       }
       
       static func request<T: Mappable>(_ apiRouter: APIRouter,_ returnType: T.Type, completion: @escaping (_ result: [T]?, _ error: BaseResponseError?) -> Void) {
           if !isConnectedToInternet() {
               // Xử lý khi lỗi kết nối internet
               SVProgressHUD.dismiss();
               return
           }
           
           AF.request(apiRouter).responseObject {(response: AFDataResponse<BaseResponse<T>>) in
               switch response.result {
               case .success:
                   print(response.result)
                   if response.response?.statusCode == 200 {
                    if (response.value!.isSuccessCode())! {
                        completion((response.value?.result)!, nil)
                           
                       } else {
                           let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.API_ERROR, (response.value?.code)!, (response.value?.error)!)
                           completion(nil, err)
                       }
                   }
                   else if response.response?.statusCode == 401 {
                       let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, (response.response?.statusCode)!, "(Request is error!)")
                       print("error 401 authen ")
                       completion(nil, err)
                       
                   }
                   else {
                       let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, (response.response?.statusCode)!, "(Request is error!)")
                       completion(nil, err)
                   }
                   break
                   
               case .failure(let error):
                   if error is AFError {
                       let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, error._code, "Request is error!")
                       completion(nil, err)
                   }
                   print(response)
                   break
               }
           }
           
           
           
       }
       
       static func requestObject<T: Mappable>(_ apiRouter: APIRouter,_ returnType: T.Type, completion: @escaping (_ result: T?, _ error: BaseResponseError?) -> Void) {
           if !isConnectedToInternet() {
               // Xử lý khi lỗi kết nối internet
               
               return
           }
           
           AF.request(apiRouter).responseObject {(response: AFDataResponse<BaseObjectResponse<T>>) in
               switch response.result {
               case .success:
                   if response.response?.statusCode == 200 {
                       if (response.value?.isSuccessCode())! {
                           completion((response.value?.result), nil)
                       } else {
                           let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.API_ERROR, (response.value?.code)!, (response.value?.error)!)
                           completion(nil, err)
                       }
                   }
                   else if response.response?.statusCode == 401 {
                       let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, (response.response?.statusCode)!, "(Authen!)")
                       completion(nil, err)
                   }
                   else {
                       let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, (response.response?.statusCode)!, "(Request is error!)")
                       completion(nil, err)
                   }
                   break

               case .failure(let error):
                   if error is AFError {
                       print(response)
                       let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, error._code, "Request is error!")
                       completion(nil, err)


                   }

                   break
               }
           }
           
           
           
       }
       
       static func requestCustom(_ apiRouter: APIRouter,completionHandler: @escaping (_ result: [String: Any]?, _ error: BaseResponseError?) -> Void) {

        if !isConnectedToInternet() {
            // Xử lý khi lỗi kết nối internet
            let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, 000, "No internet access!")
            completionHandler(nil, err)
            return
        }
        
           AF.request(apiRouter).responseJSON(completionHandler: { (response: AFDataResponse<Any>) in
               switch response.result {
               case .success(let JSON):
                   if response.response?.statusCode == 200 {
                        completionHandler((JSON as! [String : Any]), nil)
                   } else if (response.response?.statusCode == 204){
                        completionHandler(nil, nil);
                   } else if response.response?.statusCode == 401{
                        let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, response.response!.statusCode, "Lỗi xác thực tài khoản!")
                        completionHandler(nil, err)
                        print("authen 401")
                   }else{
                        let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, response.response!.statusCode, "\(JSON)")
                        completionHandler(nil, err)
                       print(response)
                   }
                   break
               case .failure(let error):
                    let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, response.response!.statusCode, error.errorDescription!)
                    completionHandler(nil, err)
                   print(error)
               }
           })
       }
       
}


