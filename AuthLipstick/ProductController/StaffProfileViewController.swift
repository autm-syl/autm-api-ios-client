//
//  StaffProfileViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import YPImagePicker
import SVProgressHUD
import SDWebImage
import SideMenu

class StaffProfileViewController: UIViewController {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var roleField: UITextField!
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var pickImageBtn: UIButton!
    
    var url_avatar:String = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user_infor = Globalvariables.shareInstance.getUserProfile();
        self.setUserInformation(user: user_infor);
    }
    
    @IBAction func updateBtnClicked(_ sender: Any) {
        let name = self.nameField.text;
        let mail = self.mailField.text;
        if ((name!.isEmpty) || (mail!.isEmpty)){
            //
            SVProgressHUD.showError(withStatus: "Điền đầy đủ thông tin");
            SVProgressHUD.dismiss(withDelay: 2.0);
            return;
        }
        if (Validator().isValidEmail(candidate: mail!) == false) {
            SVProgressHUD.showError(withStatus: "Email không đúng định dạng!");
            
            SVProgressHUD.dismiss(withDelay: 2.0);
            return;
        }
        
        
        self.updateProfile(email: mail!, name: name!, avatar: self.url_avatar);
    }
    @IBAction func pickImageBtnClicked(_ sender: Any) {
        self.showPicturePicker()
    }
    @IBAction func menuBtnClicked(_ sender: Any) {
        let menu = SideMenuManager.defaultManager.leftMenuNavigationController;
        present(menu!, animated: true, completion: nil)
    }
    
    private func setUserInformation(user:UserInformationResponse?){
        
        //
        if (nil == user){
            return;
        }
        let avatar = user!.avatar;
        self.url_avatar = avatar;
        
        let name = user!.name;
        let mail = user!.mail;
        let role = user!.role;
        if !(avatar.isEmpty){
            self.avatar!.sd_setImage(with: URL.init(string: avatar), placeholderImage: UIImage.init(named: "logo"), options: SDWebImageOptions.progressiveLoad, completed: nil);
        }
        
        self.nameField.text = name;
        self.mailField.text = mail;
        self.roleField.text = role;
    }
    
    func showPicturePicker(){
                
            var config = YPImagePickerConfiguration();
            config.isScrollToChangeModesEnabled = true;
            config.onlySquareImagesFromCamera = true;
            config.usesFrontCamera = false;
            config.showsPhotoFilters = true;
            config.shouldSaveNewPicturesToAlbum = false;
            config.albumName = "AuthLipstick";
            config.startOnScreen = YPPickerScreen.library;
            config.screens = [.library, .photo];
            config.showsCrop = .none;
            config.targetImageSize = YPImageSize.original;
            config.overlayView = UIView();
            config.hidesStatusBar = true;
            config.hidesBottomBar = false;
            config.preferredStatusBarStyle = UIStatusBarStyle.default;
            config.bottomMenuItemSelectedColour = UIColor.init(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 1.0)
            config.bottomMenuItemUnSelectedColour = UIColor.init(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0);
        //        config.filters = [DefaultYPFilters...]
                
            config.library.options = nil;
            config.library.onlySquare = false;
            config.library.minWidthForItem = nil;
            config.library.mediaType = YPlibraryMediaType.photo;
            config.library.maxNumberOfItems = 1;
            config.library.minNumberOfItems = 1;
            config.library.numberOfItemsInRow = 4;
            config.library.spacingBetweenItems = 1.0;
            config.library.skipSelectionsGallery = false;
                
                
            let picker = YPImagePicker(configuration: config);
                
            picker.didFinishPicking { [unowned picker] items, cancelled in
                
                if (cancelled){
                    //
                    print("Picker was canceled");
                }
                if let photo = items.singlePhoto {
                    // lay dc anh o day photo.image up load len server lay url ve
                    
                    self.avatar.image = photo.image;
                    let name = Utility().currentDateToString();
                    let img_resize = Utility().resizeImageTofill(image: photo.image)
                    let file = img_resize.pngData()?.base64EncodedString(); // base64
                    
                    SVProgressHUD.show();
                    
                    MonConnection.requestCustom(APIRouter.uploadImage(name: name, file: file!)) { (result, error) in
                        //
                        
                        if (error == nil) {
                            let result_upload = UploadResponse.init(JSON: result!);
                            let id = result_upload?.id;
                            let img_url = "\(Config.BASE_URL)api/v1/image?id=\(id ?? 0)";
                            self.url_avatar = img_url;
                            
                            //
                            if !(img_url.isEmpty){
                                self.avatar!.sd_setImage(with: URL.init(string: img_url), placeholderImage: UIImage.init(named: "logo"), options: SDWebImageOptions.progressiveLoad, completed: nil);
                            }
                        } else {
                            print("APIRouter.register Failed: \(String(describing: error?.mErrorMessage))")
                            SVProgressHUD.showError(withStatus: "Tải ảnh lên thất bại!");
                            SVProgressHUD.dismiss(withDelay: 2.0);
                        }
                        SVProgressHUD.dismiss();
                    }
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }

    func updateProfile(email:String, name:String, avatar:String){
        SVProgressHUD.show()
        MonConnection.requestCustom(APIRouter.updateProfile(email: email, name: name, avatar: avatar)) { (result, error) in
            //
            SVProgressHUD.dismiss();
            if (error == nil) {
                let profile:UserInformationResponse = UserInformationResponse.init(JSON: result!)!;
                Globalvariables.shareInstance.setUserProfile(profile: profile);
                
                self.setUserInformation(user: profile);
                SVProgressHUD.showSuccess(withStatus: "Sửa thông tin thành công");
                SVProgressHUD.dismiss(withDelay: 2.0);
            } else {
                print("APIRouter.register Failed: \(String(describing: error?.mErrorMessage))")
                 SVProgressHUD.showError(withStatus: "Không sửa được thông tin cá nhân vào lúc này!");
                SVProgressHUD.dismiss(withDelay: 2.0);
                return;
            }
        }
    }
}
