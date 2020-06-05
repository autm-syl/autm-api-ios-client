//
//  EditProductViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/15/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import YPImagePicker
import SVProgressHUD
import SDWebImage
import SideMenu

import IQKeyboardManager

class EditProductViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var categoryField: SearchTextField!
    @IBOutlet weak var barcodeField: UITextField!
    @IBOutlet weak var skuField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var ingredientTextView: UITextView!
    @IBOutlet weak var usesTextView: UITextView!
    @IBOutlet weak var collectionImagesPreview: UICollectionView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var skinsTypeField: SearchTextField!
    
    @IBOutlet weak var popupText: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var scanBtn: UIButton!
    
    var cate_sugest_lst:[SearchTextFieldItem] = [];
    var cate_sugest_lst_show:[SearchTextFieldItem] = [];
    var skintype_sugest_lst:[SearchTextFieldItem] = [];
    
    var lst_url_images: [String] = [""];
    
    var categorySelected:SearchTextFieldItem?
    var skintypeSelected:SearchTextFieldItem?
    open var product:Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.settingCollection();
        self.collectionImagesPreview.reloadData();
        
        // setting delegate
        self.descriptionTextView.delegate = self;
        self.ingredientTextView.delegate = self;
        self.usesTextView.delegate = self;
        self.contentText.delegate = self;
        
        self.categoryField.delegate = self;
        self.skinsTypeField.delegate = self;
        
        // load data
        self.settingAsync();
        
        self.fillAllField();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
//        IQKeyboardManager.shared().shouldResignOnTouchOutside = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    
    func settingAsync(){
        SVProgressHUD.show()
        self.configCategoryField();
        self.configskinsTypeField();
        self.loadListCategory();
        self.loadListSkinType();
    }
    
    private func fillAllField(){
        self.barcodeField.text = product?.barcode;
        self.categorySelected = SearchTextFieldItem.init(title: product!.category_name, subtitle: "", image: nil, id:Int(product!.category_id)!);
        self.categoryField.text = product?.category_name;
        self.descriptionTextView.text = product?.description;
        self.ingredientTextView.text = product?.ingredient;
        self.nameField.text = product?.name;
        self.usesTextView.text = product?.uses;
        self.skuField.text = product?.cost;
           
            
        self.lst_url_images = product!.previews;
        self.lst_url_images.append("");
        self.collectionImagesPreview.reloadData();
    }
    
    private func settingCollection(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
       layout.itemSize = CGSize(width: 80, height: 80)
//        layout.scrollDirection = [.vertical, .ho
       layout.minimumInteritemSpacing = 0
       layout.minimumLineSpacing = 0
       collectionImagesPreview.collectionViewLayout = layout
       collectionImagesPreview.delegate = self
       collectionImagesPreview.dataSource = self
       
       collectionImagesPreview.register(
           UINib(nibName: "ImageProductPreviewCell", bundle: Bundle(for: ImageProductPreviewCell.self)),
           forCellWithReuseIdentifier: "ImageProductPreviewCell")
    }
    
    private func configCategoryField(){
        categoryField.theme = SearchTextFieldTheme.lightTheme();
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: categoryField.frame.width, height: 30))
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(1.0)
        header.textAlignment = .center
        header.font = UIFont.systemFont(ofSize: 14)
        header.text = "Chọn một loại có sẵn";
        categoryField.resultsListHeader = header
        
        // Modify current theme properties
       categoryField.theme.font = UIFont.systemFont(ofSize: 12)
       categoryField.theme.bgColor = UIColor.white.withAlphaComponent(1.0)
       categoryField.theme.borderColor = UIColor.lightGray.withAlphaComponent(1)
       categoryField.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1)
       categoryField.theme.cellHeight = 50
       categoryField.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        categoryField.maxNumberOfResults = 100;
        // Max results list height - Default: No limit
        categoryField.maxResultsListHeight = 400;
        // Set specific comparision options - Default: .caseInsensitive
        categoryField.comparisonOptions = [.caseInsensitive];
        // You can force the results list to support RTL languages - Default: false
        categoryField.forceRightToLeft = false;
        
        // Handle item selection - Default behaviour: item title set to the text field
        categoryField.itemSelectionHandler = { filteredResults, itemPosition in
                  // Just in case you need the item position
                  let item = filteredResults[itemPosition]
                  
                  // Do whatever you want with the picked item
                  self.categoryField.text = item.title
                  self.categoryField.endEditing(true);
                  self.categorySelected = item;
              }
        
        categoryField.userStoppedTypingHandler = {
                    if let criteria = self.categoryField.text {
                        if criteria.count > 1 {
                            self.categoryField.showLoadingIndicator()
        //                    self.searchField.endEditing(true);
                            
                            let result = self.fillterCategories(text:criteria)
                            
                            self.categoryField.filterItems(result)
                            // Stop loading indicator
                            self.categoryField.stopLoadingIndicator()
                        }
                    }
                } as (() -> Void)
        // Update data source when the user stops typing
        categoryField.forceNoFiltering = true;
        
        self.categoryField.showLoadingIndicator();
    }
    
    private func configskinsTypeField(){
        skinsTypeField.theme = SearchTextFieldTheme.lightTheme();
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: skinsTypeField.frame.width, height: 30))
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(1.0)
        header.textAlignment = .center
        header.font = UIFont.systemFont(ofSize: 14)
        header.text = "Chọn một loại có sẵn";
        skinsTypeField.resultsListHeader = header
        
        // Modify current theme properties
       skinsTypeField.theme.font = UIFont.systemFont(ofSize: 12)
       skinsTypeField.theme.bgColor = UIColor.white.withAlphaComponent(1.0)
       skinsTypeField.theme.borderColor = UIColor.lightGray.withAlphaComponent(1)
       skinsTypeField.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1)
       skinsTypeField.theme.cellHeight = 50
       skinsTypeField.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        skinsTypeField.maxNumberOfResults = 100;
        // Max results list height - Default: No limit
        skinsTypeField.maxResultsListHeight = 400;
        // Set specific comparision options - Default: .caseInsensitive
        skinsTypeField.comparisonOptions = [.caseInsensitive];
        // You can force the results list to support RTL languages - Default: false
        skinsTypeField.forceRightToLeft = false;
        
        // Handle item selection - Default behaviour: item title set to the text field
        skinsTypeField.itemSelectionHandler = { filteredResults, itemPosition in
                  // Just in case you need the item position
                  let item = filteredResults[itemPosition]
                  
                  // Do whatever you want with the picked item
                  self.skinsTypeField.text = item.title
                  self.skinsTypeField.endEditing(true);
                  self.skintypeSelected = item;
              }
        
        
        // Update data source when the user stops typing
        skinsTypeField.forceNoFiltering = true;
        
        self.skinsTypeField.showLoadingIndicator();
    }
    
    private func loadListCategory() {
        MonConnection.requestCustom(APIRouter.category) { (result, error) in
            //
            if (error == nil) {
                let cateresult = CategoriesResult.init(JSON: result!);
                //
                cateresult?.lstCategory.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: item.ext, image: nil, id: item.id);
                    self.cate_sugest_lst.append(item);
                });
                
                self.cate_sugest_lst_show = self.cate_sugest_lst;
                self.categoryField.filterItems(self.cate_sugest_lst_show);
                self.categoryField.stopLoadingIndicator();
                
                Globalvariables.shareInstance.setLocalAllcategores(allcategories: cateresult!);
            } else {
                SVProgressHUD.showError(withStatus: "Error!\nDanh sách các loại sản phẩm được lấy từ dữ liệu cũ!");
                SVProgressHUD.dismiss(withDelay: 4.0);
                
                let cateresult = Globalvariables.shareInstance.getLocalAllcategores()
                cateresult.lstCategory.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: item.ext, image: nil, id: item.id);
                    self.cate_sugest_lst.append(item);
                });
                
                self.cate_sugest_lst_show = self.cate_sugest_lst;
                self.categoryField.filterItems(self.cate_sugest_lst_show);
                self.categoryField.stopLoadingIndicator();
            }
            SVProgressHUD.dismiss()
        }
    }
    
    private func loadListSkinType() {
        MonConnection.requestCustom(APIRouter.skinstype) { (result, error) in
            //
            if (error == nil) {
                let cateresult = SkinsTypesResult.init(JSON: result!);
                //
                cateresult?.lstSkinsType.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: item.ext, image: nil, id: item.id);
                    self.skintype_sugest_lst.append(item);
                });
                
                self.skinsTypeField.filterItems(self.skintype_sugest_lst)
                self.skinsTypeField.stopLoadingIndicator();
                
                Globalvariables.shareInstance.setLocalAllSkinsType(allSkins: cateresult!)
            } else {
                SVProgressHUD.showError(withStatus: "Error!\nDanh sách các loại da được lấy từ dữ liệu cũ!");
                SVProgressHUD.dismiss(withDelay: 4.0);
                
                let cateresult = Globalvariables.shareInstance.getLocalAllSkinsType()
                cateresult.lstSkinsType.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: item.ext, image: nil, id: item.id);
                    self.skintype_sugest_lst.append(item);
                });
                
                self.skinsTypeField.filterItems(self.skintype_sugest_lst)
                self.skinsTypeField.stopLoadingIndicator();
            }
            SVProgressHUD.dismiss()
        }
    }
    
    
    // action
    @IBAction func doneBtnClicked(_ sender: Any) {
        
        if (self.categorySelected == nil) {
            SVProgressHUD.showError(withStatus: "Chọn danh mục có sẵn bên dưới!");
            SVProgressHUD.dismiss(withDelay: 2.0);
        }
        if (self.skintypeSelected == nil) {
           SVProgressHUD.showError(withStatus: "Chọn những loại có sẵn bên dưới");
           SVProgressHUD.dismiss(withDelay: 2.0);
            return;
        }
        
        let barcode = self.barcodeField.text;
        let category_id = self.categorySelected?.id;
        let category_name = self.categoryField.text;
        let skinstype_name = self.skinsTypeField.text;
        let description = self.descriptionTextView.text;
        let ext = product?.ext;
        let ingredient = self.ingredientTextView.text;
        let name = self.nameField.text;
        let sku = product?.sku;
        let uses = self.usesTextView.text;
        let cost = self.skuField.text;
        
        let id = product?.id
        
        if ((barcode!.isEmpty)||(category_name!.isEmpty)||(skinstype_name!.isEmpty)||(description!.isEmpty)||(ingredient!.isEmpty)||(uses!.isEmpty)||(cost!.isEmpty)) {
            SVProgressHUD.showError(withStatus: "Cần điền đầy đủ thông tin");
            SVProgressHUD.dismiss(withDelay: 2.0);
            return;
        }
        if (lst_url_images.count > 0) {
            self.lst_url_images.remove(at: lst_url_images.count-1)
        }
        
        let previews:[String] = self.lst_url_images;
        
        MonConnection.requestCustom(APIRouter.update_product(id:id!, name: name!, barcode: barcode!, preview: previews, sku: sku!, cate_id: "\(category_id ?? 0)", cate_name: category_name!, description: description!, ext: ext!, ingredient: ingredient!, uses: uses!, cost: cost!, skinstype_name: skinstype_name!)) { (result, error) in
            //
            if (error == nil){
                let result_products = AddproductResult.init(JSON: result!);
                if (result_products?.product != nil){
                    SVProgressHUD.showSuccess(withStatus: "Sửa thông tin sản phẩm thành công");
                    SVProgressHUD.dismiss(withDelay: 2.0);
                    return;
                }
                SVProgressHUD.showError(withStatus: "Lỗi không biết");
                SVProgressHUD.dismiss(withDelay: 4.0);
            } else {
                SVProgressHUD.showError(withStatus: "Error!\n\(error?.mErrorMessage ?? "Unknow")");
                SVProgressHUD.dismiss(withDelay: 4.0);
            }
        }
        
        
        
    }
    @IBAction func scanBtnClicked(_ sender: Any) {
        //
        let scanView:ScanViewController = ScanViewController(nibName: "ScanViewController", bundle: nil);
        scanView.delegate = self;
        self.present(scanView, animated: true, completion: nil)
    }
    
    @IBAction func menuBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    
    @IBAction func costValidatorChanged(_ sender: UITextField) {
        if let amountString = self.skuField.text?.currencyInputFormatting() {
            self.skuField.text = amountString
        }
    }
}

extension EditProductViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lst_url_images.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageProductPreviewCell", for: indexPath) as! ImageProductPreviewCell
        if (indexPath.row == (lst_url_images.count - 1)) {
            // last
            cell.nonImage(isImage: true);
       } else {
            cell.nonImage(isImage: false);
            let url_img = URL.init(string: lst_url_images[indexPath.row]);
            cell.imgThumb!.sd_setImage(with: url_img, placeholderImage: UIImage.init(named: "logo"), options: SDWebImageOptions.progressiveLoad, completed: nil);
        }
        cell.delegate = self;
        
        return cell
    }

}

extension EditProductViewController:ImageProductPreviewCellDelegate {
    func didRemoveItem(item: ImageProductPreviewCell) {
        //
        let index = collectionImagesPreview.indexPath(for: item);
        
        self.collectionImagesPreview.deleteItems(at: [index!]);
        self.lst_url_images.remove(at: index!.item)
        
//        let cacheReuseCell:NSMutableDictionary = self.collectionImagesPreview.value(forKey: "_reusableCollectionCells") as! NSMutableDictionary;
//        cacheReuseCell.removeAllObjects()
        self.collectionImagesPreview.reloadData()
    }
    
    func didAddMoreItem() {
        // call camera, image picker
        self.showPicturePicker()
    }
}

// handle picker image
extension EditProductViewController {
     func showPicturePicker(){
            
        var config = YPImagePickerConfiguration();
        config.isScrollToChangeModesEnabled = true;
        config.onlySquareImagesFromCamera = true;
        config.usesFrontCamera = false;
        config.showsPhotoFilters = false;
        config.shouldSaveNewPicturesToAlbum = false;
        config.albumName = "AuthLipstick";
        config.startOnScreen = YPPickerScreen.library;
        config.screens = [.library, .photo];
        config.showsCrop = .none;
        config.targetImageSize = YPImageSize.original;
        config.overlayView = UIView();
        config.hidesStatusBar = false;
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
                let name = Utility().currentDateToString();
                let img_resize = Utility().resizeImageTofill(image: photo.image)
                let file = img_resize.pngData()?.base64EncodedString(); // base64
                
                SVProgressHUD.show();
                
                MonConnection.requestCustom(APIRouter.uploadImage(name: name, file: file!)) { (result, error) in
                    //
                    SVProgressHUD.dismiss();
                    if (error == nil) {
                        let result_upload = UploadResponse.init(JSON: result!);
                        let id = result_upload?.id;
                        let img_url = "\(Config.BASE_URL)api/v1/image?id=\(id ?? 0)";
                        self.lst_url_images.insert(img_url, at: 0);
                        
//                        let cacheReuseCell:NSMutableDictionary = self.collectionImagesPreview.value(forKey: "_reusableCollectionCells") as! NSMutableDictionary;
//                        cacheReuseCell.removeAllObjects()
                        
                        self.collectionImagesPreview.reloadData()
                    } else {
                        print("APIRouter.register Failed: \(String(describing: error?.mErrorMessage))")
                        SVProgressHUD.showError(withStatus: "tải ảnh lên thất bại!");
                        SVProgressHUD.dismiss(withDelay: 2.0);
                    }
                    
                }
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    
    ///
    func fillterCategories(text:String) -> [SearchTextFieldItem]{
        self.cate_sugest_lst_show.removeAll()
        let text_cv = text.convertedToSlug();
        
        self.cate_sugest_lst.forEach { (item) in
            //
            let name = item.title;
            let name_cv = name.convertedToSlug();
            if (name.contains(text)) || (name_cv!.contains(text_cv!)) {
                // ok
                self.cate_sugest_lst_show.append(item);
            }
        }
        
        if (self.cate_sugest_lst.count == 0){
            self.cate_sugest_lst_show = self.cate_sugest_lst;
        }
        //
        return self.cate_sugest_lst_show;
    }
}

extension EditProductViewController:UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //
        if (textField == self.categoryField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        }
        if (textField == self.skinsTypeField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        }
        
        return true;
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //
        if (textField == self.categoryField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = true
            
            self.cate_sugest_lst_show = self.cate_sugest_lst;
            self.categoryField.filterItems(self.cate_sugest_lst_show);
        }
        if (textField == self.skinsTypeField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        }
        
        return true;
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // show popup
        if (textView == self.contentText) {
            return true;
        } else {
            self.popupText.isHidden = false;
            
            if (textView == descriptionTextView) {
                self.titleText.text = "Mô tả sản phẩm";
                self.contentText.text = descriptionTextView.text;
            }
            if (textView == ingredientTextView) {
                self.titleText.text = "Thành phần(cấu tạo)";
                self.contentText.text = ingredientTextView.text;
            }
            if (textView == usesTextView) {
                self.titleText.text = "Cách sử dụng";
                self.contentText.text = usesTextView.text;
            }
            
            self.contentText.becomeFirstResponder();
        }
        return false;
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView == contentText) {
            //
            let text = textView.text;
            textView.text = "";
            if (titleText.text == "Mô tả sản phẩm") {
                self.descriptionTextView.text = text;
            }
            
            if (titleText.text == "Thành phần(cấu tạo)") {
                self.ingredientTextView.text = text;
            }
            
            if (titleText.text == "Cách sử dụng") {
                self.usesTextView.text = text;
            }
            
            self.view.endEditing(true);
             self.popupText.isHidden = true;
        }
    }
}

extension EditProductViewController:ScanViewControllerDelegate {
    func scanResultValue(value: String) {
        //
        if (value.isEmpty) {
            SVProgressHUD.showError(withStatus: "Không quét được mã vạch, thử nhập bằng tay xem!");
            SVProgressHUD.dismiss(withDelay: 3.0);
        } else {
            self.barcodeField.text = value;
        }
    }
    
   
}

