//
//  Config.swift
//  AuthLipstick
//
//  Created by Sylvanas on 10/31/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
struct Config {
    static let BASE_URL : String = "https://autm.site/";
//    static let BASE_URL : String = "http://192.168.1.13:4000/"
}

enum NetworkErrorType {
    case API_ERROR
    case HTTP_ERROR
}

