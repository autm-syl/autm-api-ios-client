//
//  LoginViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailfield: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.emailfield.delegate = self;
        self.passwordField.delegate = self;
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        self.goRegisterView();
    }
    
    private func goRegisterView(){
        performSegue(withIdentifier: "goRegisterView", sender: nil);
    }
    @IBAction func LoginBtnClicked(_ sender: Any) {
        self.view.endEditing(true);
               
       let mail = emailfield.text;
       let pass = passwordField.text;
       
       if (Validator().isValidEmail(candidate: mail!) == false) {
           SVProgressHUD.showError(withStatus: "Email không đúng định dạng");
           
           SVProgressHUD.dismiss(withDelay: 2.0);
           return;
       }
       if (pass == "") {
           SVProgressHUD.showError(withStatus: "Chưa nhập mật khẩu");
           SVProgressHUD.dismiss(withDelay: 2.0);
           return;
       }
       
       self.login(mail: mail!, pass: pass!)
    }
    
}

extension LoginViewController {
    func login(mail:String, pass:String) {
        SVProgressHUD.show();
        
        MonConnection.requestCustom(APIRouter.login(email: mail, password: pass)) { (result, error) in
            //
            if (error == nil) {
                let loginres = LoginResponse.init(JSON: result!);
                let jwt = loginres?.jwt;
                if (jwt == ""){
                    //register failse
                } else {
                    Globalvariables.shareInstance.setTokenAuth(token: jwt ?? "");
                    self.getUserInfor();
                }
            } else {
                print("APIRouter.login Failed: \(String(describing: error))")
                SVProgressHUD.showError(withStatus: "Đăng nhập thất bại!");
                SVProgressHUD.dismiss(withDelay: 2.0);
            }
        }
    }
    
    func getUserInfor() {
        MonConnection.requestCustom(APIRouter.get_profile) { (result, error) in
            if (error == nil) {
                let profile:UserInformationResponse = UserInformationResponse.init(JSON: result!)!;
                
                Globalvariables.shareInstance.setUserProfile(profile: profile);
//                self.navigationController!.dismiss(animated: true, completion: nil);
                self.navigationController!.dismiss(animated: true) {
                    //
                    let notificationName = Notification.Name("login success");
                    NotificationCenter.default.post(name:notificationName, object: nil);
                }
//
//                let notificationName = Notification.Name("login success");
//                NotificationCenter.default.post(name:notificationName, object: nil);
            } else {
                print("APIRouter.register Failed: \(String(describing: error?.mErrorMessage))")
                SVProgressHUD.showError(withStatus: "Không lấy được thông tin tài khoản!");
                SVProgressHUD.dismiss(withDelay: 2.0);
                return;
            }
             SVProgressHUD.dismiss();
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if (textField == self.passwordField){
            self.LoginBtnClicked(self.loginBtn as Any);
        }
        
        return false
    }
}

