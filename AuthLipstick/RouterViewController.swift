//
//  RouterViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/1/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SideMenu
import SVProgressHUD

class RouterViewController: UIViewController {
    @IBOutlet weak var useOfflineBtn: UIButton!
    
     let notificationName = Notification.Name("login success");
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.observerLoginSuccess), name: self.notificationName, object: nil)
        
        self.setupSideMenu();
        self.nonnet();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        SVProgressHUD.show();
        // check token
        self.getUserInfor();
    }
    
    func nonnet() {
        let categories = UserDefaults.standard.value(forKey: "categories");
        let allproduct = UserDefaults.standard.value(forKey: "allproduct");
        
        if (categories != nil ) || (allproduct != nil) {
            self.useOfflineBtn.isHidden = false;
        } else {
            self.useOfflineBtn.isHidden = true;
        }
    }
    
    @IBAction func productClicked(_ sender: Any) {
        
        SVProgressHUD.showInfo(withStatus: "Sử dụng dữ liệu cũ! \n Chế độ chỉ đọc. Không thể sửa hoặc thêm dữ liệu mới");
        SVProgressHUD.dismiss(withDelay: 4.0);
        
        self.perform(#selector(goProductsView), with: nil, afterDelay: 4.5);
        
//        self.goProductsView()
    }
    @IBAction func loginClicked(_ sender: Any) {
        self.goLoginView()
    }
    
    // private function
    @objc func observerLoginSuccess(_ notification: Notification) {
        self.goProductsView();
    }
    
    @objc private func goProductsView(){
        performSegue(withIdentifier: "goProductsView", sender: nil)
    }
    
    private func goLoginView(){
        performSegue(withIdentifier: "goLoginView", sender: nil)
    }
    
    private func setupSideMenu() {
           // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController;
        let presentationStyle = selectedPresentationStyle();
        presentationStyle.backgroundColor = .white;
        presentationStyle.menuStartAlpha = 0.8;
        presentationStyle.menuScaleFactor = 1.0;
        
        presentationStyle.onTopShadowOpacity = 0.0;
        presentationStyle.onTopShadowColor = .white;
        presentationStyle.presentingEndAlpha = 0.0;
        presentationStyle.presentingScaleFactor = 1.0;
       
        var settings = SideMenuSettings();
        settings.presentationStyle = presentationStyle;
        settings.menuWidth = min(view.frame.width, view.frame.height) * 0.8;
        settings.blurEffectStyle = .light;
        settings.statusBarEndAlpha = 0.0;
           
        SideMenuManager.default.leftMenuNavigationController?.settings = settings;
       
       
       // Enable gestures. The left and/or right menus must be set up above for these to work.
       // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar);
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view);
          
    }
    
    private func selectedPresentationStyle() -> SideMenuPresentationStyle {
        //let modes: [SideMenuPresentationStyle] = [.menuSlideIn, .viewSlideOut, .viewSlideOutMenuIn, .menuDissolveIn]
        return .menuSlideIn;
    }
    
    // API check token
    func getUserInfor() {
        MonConnection.requestCustom(APIRouter.get_profile) { (result, error) in
            SVProgressHUD.dismiss();
            if (error == nil) {
                let profile:UserInformationResponse = UserInformationResponse.init(JSON: result!)!;
                
                Globalvariables.shareInstance.setUserProfile(profile: profile);
                 self.navigationController?.dismiss(animated: true, completion: nil)
                //
                self.goProductsView();
            } else {
                print("APIRouter.register Failed: \(String(describing: error?.mErrorMessage))");
//                SVProgressHUD.showError(withStatus: "Lấy thông tin thất bại! \n Cần đăng nhập!");
                SVProgressHUD.dismiss(withDelay: 2.0);
                self.goLoginView();
                return;
            }
             SVProgressHUD.dismiss();
        }
    }

}

