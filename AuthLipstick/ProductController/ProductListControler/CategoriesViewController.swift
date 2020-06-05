//
//  CategoriesViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import IQKeyboardManager
import SideMenu

class CategoriesViewController: UIViewController {
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var compareBtn: UIButton!
    @IBOutlet weak var searchField: SearchTextField!
    @IBOutlet weak var productsResultsTable: UITableView!
    @IBOutlet weak var skintypeField: SearchTextField!
    
    var categorySelected:SearchTextFieldItem?
    var skinstypeSelected:SearchTextFieldItem?
    var lst_all_product:[Product] = []
    var lst_show_product:[Product] = []
    var cate_sugest_lst:[SearchTextFieldItem] = [];
    var skin_sugest_lst:[SearchTextFieldItem] = [];
    
    var cate_sugest_lst_show:[SearchTextFieldItem] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productsResultsTable.delegate = self;
        productsResultsTable.dataSource = self;
        productsResultsTable.separatorColor = UIColor.clear;
        productsResultsTable.register(UINib.init(nibName: "ProductCell", bundle: Bundle(for: ProductCell.self)), forCellReuseIdentifier: "ProductCell")
        
        searchField.delegate = self;
        skintypeField.delegate = self;
        
        self.getListProduct();
        self.configCategoryField();
        self.configSkinTypeField();
        self.loadListCategory();
        self.loadListSkinType();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
    }
    @IBAction func menuBtnClicked(_ sender: Any) {
        let menu = SideMenuManager.defaultManager.leftMenuNavigationController;
        present(menu!, animated: true, completion: nil)
    }
    @IBAction func compareBtnClicked(_ sender: Any) {
        self.showCompareView()
    }
    
    
    private func configSkinTypeField(){
       skintypeField.theme = SearchTextFieldTheme.lightTheme();
       
       let header = UILabel(frame: CGRect(x: 0, y: 0, width: skintypeField.frame.width, height: 30))
       header.backgroundColor = UIColor.lightGray.withAlphaComponent(1.0)
       header.textAlignment = .center
       header.font = UIFont.systemFont(ofSize: 14)
       header.text = "Chọn một loại có sẵn";
       skintypeField.resultsListHeader = header
       
       // Modify current theme properties
      skintypeField.theme.font = UIFont.systemFont(ofSize: 12)
      skintypeField.theme.bgColor = UIColor.white.withAlphaComponent(1.0)
      skintypeField.theme.borderColor = UIColor.lightGray.withAlphaComponent(1)
      skintypeField.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1)
      skintypeField.theme.cellHeight = 50
      skintypeField.theme.placeholderColor = UIColor.lightGray
       
       // Max number of results - Default: No limit
       skintypeField.maxNumberOfResults = 100;
       // Max results list height - Default: No limit
       skintypeField.maxResultsListHeight = 400;
       // Set specific comparision options - Default: .caseInsensitive
       skintypeField.comparisonOptions = [.caseInsensitive];
       // You can force the results list to support RTL languages - Default: false
       skintypeField.forceRightToLeft = false;
       
       // Handle item selection - Default behaviour: item title set to the text field
       skintypeField.itemSelectionHandler = { filteredResults, itemPosition in
                 // Just in case you need the item position
                 let item = filteredResults[itemPosition]
                 
                 // Do whatever you want with the picked item
                 self.skintypeField.text = item.title
                 self.skintypeField.endEditing(true);
                 self.skinstypeSelected = item;
        
                 self.searchWithText();
             }
       
       
       // Update data source when the user stops typing
       skintypeField.forceNoFiltering = true;
       
       self.skintypeField.showLoadingIndicator();
   }
     private func configCategoryField(){
        searchField.theme = SearchTextFieldTheme.lightTheme();
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: searchField.frame.width, height: 30))
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(1.0)
        header.textAlignment = .center
        header.font = UIFont.systemFont(ofSize: 14)
        header.text = "Chọn danh mục có sẵn";
        searchField.resultsListHeader = header
        
        // Modify current theme properties
       searchField.theme.font = UIFont.systemFont(ofSize: 12)
       searchField.theme.bgColor = UIColor.white.withAlphaComponent(1.0)
       searchField.theme.borderColor = UIColor.lightGray.withAlphaComponent(1)
       searchField.theme.separatorColor = UIColor.lightGray.withAlphaComponent(1)
       searchField.theme.cellHeight = 50
       searchField.theme.placeholderColor = UIColor.lightGray
        
        // Max number of results - Default: No limit
        searchField.maxNumberOfResults = 100;
        // Max results list height - Default: No limit
        searchField.maxResultsListHeight = 400;
        // Set specific comparision options - Default: .caseInsensitive
        searchField.comparisonOptions = [.caseInsensitive];
        // You can force the results list to support RTL languages - Default: false
        searchField.forceRightToLeft = false;
        
        // Handle item selection - Default behaviour: item title set to the text field
        searchField.itemSelectionHandler = { filteredResults, itemPosition in
                  // Just in case you need the item position
              let item = filteredResults[itemPosition]
              
              // Do whatever you want with the picked item
              self.searchField.text = item.title
              self.searchField.endEditing(true);
              self.categorySelected = item;
            
              self.searchWithText();
        }
        
        searchField.userStoppedTypingHandler = {
            if let criteria = self.searchField.text {
                if criteria.count > 1 {
                    self.searchField.showLoadingIndicator()
//                    self.searchField.endEditing(true);
                    
                    let result = self.fillterCategories(text:criteria)
                    
                    self.searchField.filterItems(result)
                    // Stop loading indicator
                    self.searchField.stopLoadingIndicator()
                }
            }
        } as (() -> Void)
        // Update data source when the user stops typing
        searchField.forceNoFiltering = true;
    }
    
    private func loadListCategory() {
        MonConnection.requestCustom(APIRouter.category) { (result, error) in
            //
            if (error == nil) {
                let cateresult = CategoriesResult.init(JSON: result!);
                //
                cateresult?.lstCategory.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: "", image: nil, id: item.id);
                    self.cate_sugest_lst.append(item);
                });
                self.cate_sugest_lst_show = self.cate_sugest_lst;
                self.searchField.filterItems(self.cate_sugest_lst_show);
                self.searchField.stopLoadingIndicator();
                
                Globalvariables.shareInstance.setLocalAllcategores(allcategories: cateresult!);
            } else {
                SVProgressHUD.showError(withStatus: "Error!\nDanh sách các loại sản phẩm được lấy từ dữ liệu cũ!");
                SVProgressHUD.dismiss(withDelay: 4.0);
                
                let cateresult = Globalvariables.shareInstance.getLocalAllcategores()
                cateresult.lstCategory.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: "", image: nil, id: item.id);
                    self.cate_sugest_lst.append(item);
                });
                
                self.cate_sugest_lst_show = self.cate_sugest_lst;
                self.searchField.filterItems(self.cate_sugest_lst_show);
                self.searchField.stopLoadingIndicator();
            }
            
//            SVProgressHUD.dismiss()
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
                    self.skin_sugest_lst.append(item);
                });
                
                self.skintypeField.filterItems(self.skin_sugest_lst)
                self.skintypeField.stopLoadingIndicator();
                
                Globalvariables.shareInstance.setLocalAllSkinsType(allSkins: cateresult!)
            } else {
                SVProgressHUD.showError(withStatus: "Error!\nDanh sách các loại da được lấy từ dữ liệu cũ!");
                SVProgressHUD.dismiss(withDelay: 4.0);
                
                let cateresult = Globalvariables.shareInstance.getLocalAllSkinsType()
                cateresult.lstSkinsType.forEach({ (item) in
                    //
                    let item = SearchTextFieldItem(title: item.name, subtitle: item.ext, image: nil, id: item.id);
                    self.skin_sugest_lst.append(item);
                });
                
                self.skintypeField.filterItems(self.skin_sugest_lst)
                self.skintypeField.stopLoadingIndicator();
            }
            SVProgressHUD.dismiss()
        }
    }
    
    func getListProduct(){
           SVProgressHUD.show()
           MonConnection.requestCustom(APIRouter.all_product) { (result, error) in
               SVProgressHUD.dismiss()
               if (error == nil){
                   let product_result = AllProductsResponse.init(JSON: result!);
                   let lst = product_result?.products;
                   
                   self.lst_all_product = lst!;
                   self.lst_show_product = lst!
                   self.productsResultsTable.reloadData();
                   
                   //set to global
                   Globalvariables.shareInstance.listAllproduct = lst!;
                Globalvariables.shareInstance.setLocalAllproduct(allproducts: product_result!);
               } else {
                   SVProgressHUD.showError(withStatus: "Error!\nDanh sách sản phẩm được lấy từ dữ liệu cũ!");
                   SVProgressHUD.dismiss(withDelay: 4.0);
                   
                   let product_result = Globalvariables.shareInstance.getLocalAllproduct()
                let lst = product_result.products;
                self.lst_all_product = lst;
                self.lst_show_product = lst;
                   self.productsResultsTable.reloadData();
                   return;
               }
               
        }
    }
    private func showDetailProduct(product:Product){
        performSegue(withIdentifier: "showDetailProduct", sender: product);
    }
    
    private func showCompareView(){
        performSegue(withIdentifier: "showCompareView", sender: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        let product = sender as? Product
        if segue.identifier == "showDetailProduct" {
            if let destinationVC = segue.destination as? DetailsViewController {
                destinationVC.product = product;
            }
        }
    }
}

extension CategoriesViewController:UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //
        if (textField == self.searchField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        }
        
        if (textField == self.skintypeField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = false
        }
        
        return true;
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        //
        if (textField == self.searchField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = true
            
            self.cate_sugest_lst_show = self.cate_sugest_lst;
            self.searchField.filterItems(self.cate_sugest_lst_show);
        }
        
        if (textField == self.skintypeField){
            IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        }
        self.searchWithText();
        
        return true;
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    // Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lst_show_product.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80;
    }

    // Provide a cell object for each row.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // Fetch a cell of the appropriate type.
        let cell:ProductCell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)  as! ProductCell;
        let item = self.lst_show_product[indexPath.row];
        var thumb:String = "";
        
        if (item.previews.count != 0){
            thumb = item.previews[0];
        }
        
        cell.nameLbl.text = item.name;
        cell.costLbl.text = "\(item.cost )\n 🇻🇳";
        
        if !(thumb.isEmpty) {
            cell.thumbnail!.sd_setImage(with: URL.init(string: thumb), placeholderImage: UIImage.init(named: "logo"), options: SDWebImageOptions.progressiveLoad, completed: nil);
        } else {
            cell.thumbnail.image = UIImage.init(named: "logo");
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(red: 230.0/255, green: 230.0/255, blue: 230.0/255, alpha: 0.1);
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
//    func tableviewprepare
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let addToCompare = UITableViewRowAction(style: .destructive, title: "Thêm vào so sánh") { (action, indexPath) in
            let item = self.lst_show_product[indexPath.row];
            Globalvariables.shareInstance.addToCompare(product: item);
            
            SVProgressHUD.showSuccess(withStatus: "Đã thêm vào so sánh");
            SVProgressHUD.dismiss(withDelay: 3.0);
        }
        addToCompare.backgroundColor = UIColor.blue;

        return [addToCompare]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.lst_show_product[indexPath.row];
        self.showDetailProduct(product: product);
    }
}


extension CategoriesViewController {
    func searchWithText() {
        let text_cate = self.searchField.text;
        let text_skin = self.skintypeField.text;
        
        
        self.lst_show_product.removeAll();
        self.lst_all_product.forEach { (item) in
            //
            let cate_name = item.category_name;
            let skin_name = item.skinstype_name;
            
            if (text_cate!.isEmpty) && (text_skin!.isEmpty){
                //
                self.lst_show_product.append(item);
            }
            
            if (text_cate!.isEmpty) && (text_skin!.isEmpty == false){
                //
                if (text_skin == skin_name) {
                    // ok
                    self.lst_show_product.append(item);
                }
            }
            if (text_cate!.isEmpty == false) && (text_skin!.isEmpty){
                //
                if (text_cate == cate_name) {
                    // ok
                    self.lst_show_product.append(item);
                }
            }
            
            if (text_cate!.isEmpty == false) && (text_skin!.isEmpty == false){
                           //
               if (text_cate == cate_name) && (text_skin == skin_name) {
                   // ok
                   self.lst_show_product.append(item);
               }
           }
            
        }
        //
        // reload
        let cacheReuseCell:NSMutableDictionary = self.productsResultsTable.value(forKey: "_reusableTableCells") as! NSMutableDictionary;
          cacheReuseCell.removeAllObjects()
          
        self.productsResultsTable.reloadData()
        self.searchField.endEditing(true)
        self.searchField.stopLoadingIndicator();
    }
    
    func searchDone(){
        self.lst_show_product.removeAll();
        self.lst_show_product = self.lst_all_product;
        let cacheReuseCell:NSMutableDictionary = self.productsResultsTable.value(forKey: "_reusableTableCells") as! NSMutableDictionary;
        cacheReuseCell.removeAllObjects()
        self.productsResultsTable.reloadData()
        
        self.searchField.stopLoadingIndicator();
    }
    
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

