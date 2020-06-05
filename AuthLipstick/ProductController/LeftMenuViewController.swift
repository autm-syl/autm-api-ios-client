//
//  LeftMenuViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SVProgressHUD

class LeftMenuViewController: UIViewController {
    @IBOutlet weak var listProductBtn: UIButton!
    @IBOutlet weak var addProductBtn: UIButton!
    @IBOutlet weak var staffProfile: UIButton!
    @IBOutlet weak var lockAppBtn: UIButton!
    @IBOutlet weak var versionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appVersion:String = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
        let appbuild:String = (Bundle.main.infoDictionary!["CFBundleVersion"] as? String)!
        self.versionLbl.text = "Version: \(appVersion) \(appbuild)";

        // Do any additional setup after loading the view.
        SVProgressHUD.show();
//        self.perform(#selector(goMainTabBar), with: nil, afterDelay: 0.5)
//        self.goMainTabBar();
    }
    
    @IBAction func listProductClicked(_ sender: Any) {
        SVProgressHUD.dismiss();
        self.goMainTabBar();
        
    }
    @IBAction func addProductClicked(_ sender: Any) {
        self.goAddProduct();
    }
    @IBAction func staffProfileClicked(_ sender: Any) {
        self.goStaffProfile();
    }
    @IBAction func lockAppClicked(_ sender: Any) {
        self.perform(#selector(goMainTabBarAndToRoot), with: nil, afterDelay: 0.2)
    }
    
    @objc private func goMainTabBar(){
        performSegue(withIdentifier: "goMainTabBar", sender: nil);
    }
    
    @objc private func goMainTabBarAndToRoot(){
        performSegue(withIdentifier: "goMainTabBar", sender: nil);
        
        let notificationName = Notification.Name("back to root controller");
        NotificationCenter.default.post(name:notificationName, object: nil);
    }
    
    private func goAddProduct(){
           performSegue(withIdentifier: "goAddProduct", sender: nil);
       }
    private func goStaffProfile(){
           performSegue(withIdentifier: "goStaffProfile", sender: nil);
       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
