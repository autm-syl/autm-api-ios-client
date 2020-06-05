//
//  AllProductViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage
import SideMenu

class AllProductViewController: UIViewController {
    @IBOutlet weak var searchProductField: SearchTextField!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var compareBtn: UIButton!
    @IBOutlet weak var productsTableView: UITableView!
    
    var lst_all_product:[Product] = []
    var lst_show_product:[Product] = []
    
    //
    let notificationName = Notification.Name("back to root controller");
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.init(red: 15.0/255, green: 116.0/255, blue: 188.0/255, alpha: 1.0);
        
        return refreshControl
    }()

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.lst_all_product.removeAll()
        self.lst_show_product.removeAll()
        let cacheReuseCell:NSMutableDictionary = self.productsTableView.value(forKey: "_reusableTableCells") as! NSMutableDictionary;
        cacheReuseCell.removeAllObjects()
        
        self.productsTableView.reloadData()
        self.getListProduct()
        refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting tableview
        productsTableView.delegate = self;
        productsTableView.dataSource = self;
        productsTableView.separatorColor = UIColor.clear;
        productsTableView.register(UINib.init(nibName: "ProductCell", bundle: Bundle(for: ProductCell.self)), forCellReuseIdentifier: "ProductCell")
        productsTableView.refreshControl = refreshControl;
        self.getListProduct();
        
        //seach field
        self.settingSearchField();
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.observerBackToRootController), name: self.notificationName, object: nil)
    }
    

    @IBAction func menuBtnClicked(_ sender: Any) {
        let menu = SideMenuManager.defaultManager.leftMenuNavigationController;
        present(menu!, animated: true, completion: nil)
    }
    @IBAction func compareBtnClicked(_ sender: Any) {
        self.showCompareView()
    }
    
    // private function
    @objc func observerBackToRootController(_ notification: Notification) {
        Globalvariables.shareInstance.cleanCacheData();
        self.navigationController?.popToRootViewController(animated: true);
    }
    
    func settingSearchField(){
        searchProductField.theme = SearchTextFieldTheme.lightTheme();
        
        searchProductField.userStoppedTypingHandler = {

            if let criteria = self.searchProductField.text {
                if criteria.count > 1 {

                    self.searchProductField.showLoadingIndicator();
                    self.searchWithText(text:criteria);
                } else {
                    self.searchDone();
                }
            }
            } as (() -> Void)
    }
    
    
    func getListProduct(){
        SVProgressHUD.show()
        MonConnection.requestCustom(APIRouter.all_product) { (result, error) in
            
            // stop refresh
            if (self.refreshControl.isHidden == false){
                self.refreshControl.endRefreshing()
            }
            SVProgressHUD.dismiss()
            if (error == nil){
                let product_result = AllProductsResponse.init(JSON: result!);
                let lst = product_result?.products;
                
                self.lst_all_product = lst!;
                self.lst_show_product = lst!
                self.productsTableView.reloadData();
                
                //set to global
                Globalvariables.shareInstance.listAllproduct = lst!;
                Globalvariables.shareInstance.setLocalAllproduct(allproducts: product_result!);
            } else {
//                SVProgressHUD.showError(withStatus: "Error!\nDanh sách sản phẩm được lấy từ dữ liệu cũ!");
//                SVProgressHUD.dismiss(withDelay: 4.0);
                
                let product_result = Globalvariables.shareInstance.getLocalAllproduct()
                let lst = product_result.products;
                self.lst_all_product = lst;
                self.lst_show_product = lst;
                self.productsTableView.reloadData();
                //
                
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
    
    private func deleteProduct(product: Product, indexPath: IndexPath){
        
        let user = Globalvariables.shareInstance.getUserProfile()
        if (nil == user){
            SVProgressHUD.showError(withStatus: "Bạn chưa đăng nhập!");
            SVProgressHUD.dismiss(withDelay: 4.0);
            return;
        }
        
        if (user!.role == "admin"){
            self.lst_show_product.remove(at: indexPath.row)
            self.productsTableView.deleteRows(at: [indexPath], with: .fade)
            
            //API
            MonConnection.requestCustom(APIRouter.remove_product(id: product.id)) { (result, error) in
                //
                if (error == nil) {
                    SVProgressHUD.showError(withStatus: "Xoá thành công");
                    SVProgressHUD.dismiss(withDelay: 4.0);
                } else {
                    SVProgressHUD.showError(withStatus: "Xoá thất bại!");
                    SVProgressHUD.dismiss(withDelay: 4.0);
                }
            }
            
        } else {
            SVProgressHUD.showError(withStatus: "Chỉ admin mới có quyền xoá sản phẩm");
            SVProgressHUD.dismiss(withDelay: 4.0);
        }
        
        
        //
    }
}

extension AllProductViewController: UITableViewDelegate, UITableViewDataSource {
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
            
            SVProgressHUD.showSuccess(withStatus: "Đã thêm vào so sánh!");
            SVProgressHUD.dismiss(withDelay: 3.0);
        }
        addToCompare.backgroundColor = UIColor.blue;

        let delete = UITableViewRowAction(style: .normal, title: "Xoá sản phẩm") { (action, indexPath) in

            let product_del = self.lst_show_product[indexPath.row];
            self.deleteProduct(product: product_del, indexPath: indexPath);
        }

        delete.backgroundColor = UIColor.red

        return [addToCompare, delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = self.lst_show_product[indexPath.row];
        self.showDetailProduct(product: product);
    }
}

extension AllProductViewController {
    func searchWithText(text: String) {
        
        self.lst_show_product.removeAll();
        
        let text_cv = text.convertedToSlug();
        self.lst_all_product.forEach { (item) in
            //
            let name = item.name;
            let name_cv = name.convertedToSlug();
            
            if ((name == text)||(name_cv == text_cv)) {
                // ok
                self.lst_show_product.append(item);
            }
        }
        //
        // reload
        let cacheReuseCell:NSMutableDictionary = self.productsTableView.value(forKey: "_reusableTableCells") as! NSMutableDictionary;
          cacheReuseCell.removeAllObjects()
          
        self.productsTableView.reloadData()
        self.searchProductField.endEditing(true)
    }
    
    func searchDone(){
        self.lst_show_product.removeAll();
        self.lst_show_product = self.lst_all_product;
        let cacheReuseCell:NSMutableDictionary = self.productsTableView.value(forKey: "_reusableTableCells") as! NSMutableDictionary;
        cacheReuseCell.removeAllObjects()
        self.productsTableView.reloadData()
        
        self.searchProductField.stopLoadingIndicator();
    }
}

