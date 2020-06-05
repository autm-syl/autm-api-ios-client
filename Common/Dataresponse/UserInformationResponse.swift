//
//  UserInformationResponse.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/6/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import ObjectMapper

class UserInformationResponse: Mappable {
    var avatar:String = ""
    var mail:String = ""
    var ext:String = ""
    var isAdmin:Bool = false
    var name:String = ""
    var role:String = "member"
    var status:String = "off"
    required init?(map: Map) {
    }
    
     func mapping(map: Map) {
        avatar <- map["avatar"];
        mail <- map["email"];
        ext <- map["ext"];
        isAdmin <- map["isAdmin"];
        name <- map["name"];
        role <- map["role"];
        status <- map["status"];
    }
}
