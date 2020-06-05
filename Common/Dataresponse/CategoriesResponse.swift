//
//  CategoriesResult.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/12/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import ObjectMapper

class CategoriesResult: Mappable {
    var id = 0;
    var name = "";
    var lstCategory:[CategoryResult] = [];
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        lstCategory <- map["data"];
    }
}

class CategoryResult: Mappable {
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

