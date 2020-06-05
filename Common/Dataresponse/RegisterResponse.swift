//
//  RegisterResponse.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/6/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import ObjectMapper

class RegisterResponse: Mappable {
    public var jwt = ""
    
    init(){}
    required init?(map: Map) {
    }
    
     func mapping(map: Map) {
        jwt <- map["jwt"];
    }
}
