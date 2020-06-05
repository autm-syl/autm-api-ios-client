//
//  UploadResponse.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/12/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//


import Foundation
import ObjectMapper

class UploadResponse: Mappable {
    var id = 0;
    var name = "";
    var data: [String : Any] = [:]
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        data <- map["data"];
        let xx = UploadDataResponse.init(JSON: data);
        id = xx!.id;
        name = xx!.name
    }
}
class UploadDataResponse: Mappable {
    var id = 0;
    var name = "";
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        id <- map["id"];
        name <- map["name"];
    }
}

