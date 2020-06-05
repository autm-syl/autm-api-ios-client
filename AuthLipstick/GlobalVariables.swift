//
//  GlobalVariables.swift
//  AuthLipstick
//
//  Created by Sylvanas on 10/31/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Globalvariables {
//    static var
    static let shareInstance = Globalvariables()
    
//    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var token_auth:String = "";
    var listCompare:[Product] = [];
    
    var listAllproduct:[Product] = [];
    
    private init () {
        _ = ""
        //
        self.getTokenAuth();
    }
    
    func cleanCacheData(){
        token_auth = "";
        //
        listCompare = [];
        listAllproduct = [];
        //
        UserDefaults.standard.removeObject(forKey: "jwt");
        UserDefaults.standard.removeObject(forKey: "profile");
        UserDefaults.standard.synchronize();
    }
    
    func setTokenAuth(token:String){
        UserDefaults.standard.setValue(token, forKey: "jwt");
        UserDefaults.standard.synchronize();
        self.token_auth = token;
    }
    
    func getTokenAuth() {
        let jwt = UserDefaults.standard.value(forKey: "jwt") as? String;
        self.token_auth = jwt ?? "";
    }
    
    //user
    func setUserProfile(profile:UserInformationResponse) {
        let profile_string:String = profile.toJSONString() ?? "";
        UserDefaults.standard.setValue(profile_string, forKey: "profile");
        UserDefaults.standard.synchronize();
    }
    
    func getUserProfile() -> UserInformationResponse? {
        let profile = UserDefaults.standard.value(forKey: "profile") as? String;
        if (nil == profile){
            return nil;
        }
        let profile_obj:UserInformationResponse = (UserInformationResponse.init(JSONString: profile ?? "") ?? nil)!;
        return profile_obj
    }
    
    //compare
    func addToCompare(product:Product){
        self.listCompare.append(product)
    }
    
    func removeToCompare(index:Int){
        self.listCompare.remove(at: index);
    }
    
    //data
    func setLocalAllproduct(allproducts:AllProductsResponse) {
        let allproducts:String = allproducts.toJSONString() ?? "";
        UserDefaults.standard.setValue(allproducts, forKey: "allproduct");
        UserDefaults.standard.synchronize();
    }
    func getLocalAllproduct() -> AllProductsResponse{
        let allproduct = UserDefaults.standard.value(forKey: "allproduct") as? String;
        let allproduct_obj:AllProductsResponse = (AllProductsResponse.init(JSONString: allproduct ?? "") ?? nil)!;
        return allproduct_obj
    }
    
    func setLocalAllcategores(allcategories:CategoriesResult) {
        let categories:String = allcategories.toJSONString() ?? "";
        UserDefaults.standard.setValue(categories, forKey: "categories");
        UserDefaults.standard.synchronize();
    }
    func getLocalAllcategores() -> CategoriesResult{
        let categories = UserDefaults.standard.value(forKey: "categories") as? String;
        let categories_obj:CategoriesResult = (CategoriesResult.init(JSONString: categories ?? "") ?? nil)!;
        return categories_obj
    }
    
    func setLocalAllSkinsType(allSkins:SkinsTypesResult) {
        let skins:String = allSkins.toJSONString() ?? "";
        UserDefaults.standard.setValue(skins, forKey: "skinstype");
        UserDefaults.standard.synchronize();
    }
    func getLocalAllSkinsType() -> SkinsTypesResult{
        let skins = UserDefaults.standard.value(forKey: "skinstype") as? String;
        let skins_obj:SkinsTypesResult = (SkinsTypesResult.init(JSONString: skins ?? "") ?? nil)!;
        return skins_obj
    }
}
