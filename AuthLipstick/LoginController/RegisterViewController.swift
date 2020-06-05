//
//  RegisterViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SVProgressHUD

class RegisterViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameField.delegate = self;
        self.emailField.delegate = self;
        self.passwordField.delegate = self;
        self.passwordConfirmField.delegate = self;
    }
    
    @IBAction func registerBtnClicked(_ sender: Any) {
        self.view.endEditing(true);
        
//        let name = nameField.text;
        let mail = emailField.text;
        let pass = passwordField.text;
        let pass_cf = passwordConfirmField.text;
        
        if (Validator().isValidEmail(candidate: mail!) == false) {
            SVProgressHUD.showError(withStatus: "Email không đúng định dạng!");
            
            SVProgressHUD.dismiss(withDelay: 2.0);
            return;
        }
        if !(pass == pass_cf) {
            SVProgressHUD.showError(withStatus: "Mật khẩu chưa trùng nhau!");
            SVProgressHUD.dismiss(withDelay: 2.0);
            return;
        }
        
        self.register(mail: mail!, pass: pass!, pass_cf: pass_cf!);
        
    }


}

extension RegisterViewController {
    func register(mail:String, pass:String, pass_cf:String) {
        SVProgressHUD.show();
        
        MonConnection.requestCustom(APIRouter.register(email: mail, password: pass, password_cf: pass_cf)) { (result, error) in
            //
            if (error == nil) {
                let result_register = RegisterResponse.init(JSON: result!);
                let jwt = result_register?.jwt;
                if (jwt == ""){
                    //register failse
                } else {
                    Globalvariables.shareInstance.setTokenAuth(token: jwt ?? "");
                    self.getUserInfor();
                }
            } else {
                print("APIRouter.register Failed: \(String(describing: error?.mErrorMessage))")
                SVProgressHUD.showError(withStatus: "Đăng ký không thành công!");
                SVProgressHUD.dismiss(withDelay: 2.0);
            }
        }
    }
    
    func getUserInfor() {
        MonConnection.requestCustom(APIRouter.get_profile) { (result, error) in
            //
            if (error == nil) {
                let result_profile = UserInformationResponse.init(JSON: result!);
                 Globalvariables.shareInstance.setUserProfile(profile: result_profile!);
                
                self.navigationController!.dismiss(animated: true) {
                    //
                    let notificationName = Notification.Name("login success");
                    NotificationCenter.default.post(name:notificationName, object: nil);
                }
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

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        if (textField == self.passwordConfirmField){
            self.registerBtnClicked(self.registerBtn as Any);
        }
        
        return false
    }
}
