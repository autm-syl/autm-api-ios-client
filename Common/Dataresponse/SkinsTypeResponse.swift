//
//  SkinsTypeResponse.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/29/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import ObjectMapper

class SkinsTypesResult: Mappable {
    var id = 0;
    var name = "";
    var lstSkinsType:[SkinsTypeResult] = [];
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        lstSkinsType <- map["data"];
    }
}

class SkinsTypeResult: Mappable {
    var id = 0;
    var name = "";
    var ext = "";
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        id <- map["id"];
        name <- map["name"];
        ext <- map["ext"];
    }
}
