//
//  AddproductResult.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/13/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import ObjectMapper

class AddproductResult: Mappable {
    var product:ProductResult?;
    var data: [String : Any] = [:]
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        data <- map["data"];
        product = ProductResult.init(JSON: data);
    }
}
class ProductResult: Mappable {
    var id = 0;
    var barcode = "";
    var category_id = "";
    var category_name = "";
    var description = "";
    var ext = "";
    var name = "";
    var ingredient = "";
    var sku = "";
    var uses = "";
    var cost = "";
    var previews:[String] = [];
    init(){}
    required init?(map: Map) {
    }
   
     func mapping(map: Map) {
        id <- map["id"];
        name <- map["name"];
        barcode <- map["barcode"];
        category_id <- map["category_id"];
        category_name <- map["category_name"];
        description <- map["description"];
        ext <- map["ext"];
        ingredient <- map["ingredient"];
        sku <- map["sku"];
        uses <- map["uses"];
        cost <- map["cost"];
        previews <- map["previews"];
    }
}
