//
//  DetailsViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/5/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import SDWebImage
import FSPagerView

class DetailsViewController: UIViewController {
    @IBOutlet weak var nameProductlbl: UILabel!
    @IBOutlet weak var tableInformation: UITableView!
    @IBOutlet weak var topview: UIView!
    @IBOutlet weak var pageControlsView: UIPageControl!
    @IBOutlet weak var editProductBtn: UIButton!
    
    var fsView:FSPagerView?
    var pageControl:FSPageControl?
    
    open var product:Product?
    
//
    override func viewDidLoad() {
        super.viewDidLoad()

        // setting table view
        tableInformation.delegate = self;
        tableInformation.dataSource = self;
        tableInformation.register(UINib.init(nibName: "DetailCellTableViewCell", bundle: Bundle(for: ProductCell.self)), forCellReuseIdentifier: "DetailCellTableViewCell");
        tableInformation.separatorColor = .clear;
        
        tableInformation.estimatedRowHeight = 240;
        tableInformation.rowHeight = UITableView.automaticDimension;
        
        self.tableInformation.reloadData();
        self.nameProductlbl.text = product?.name;
        
        // header setting
        self.perform(#selector(settingFSView), with: nil, afterDelay: 0.1);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true);
    }
    @IBAction func editProductClicked(_ sender: Any) {
        self.editProductView();
    }
    
    //
    @objc func settingFSView(){
        fsView = FSPagerView.init(frame: self.topview.bounds);
        fsView?.dataSource = self;
        fsView?.delegate = self;
        fsView?.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell");
        fsView?.automaticSlidingInterval = 5.0;
        self.topview.addSubview(fsView!);
        
        pageControl = FSPageControl(frame: self.pageControlsView.bounds);
        
        self.view.addSubview(pageControl!)
        
        pageControl?.autoresizingMask = .flexibleWidth
        pageControl?.setFillColor(UIColor.init(red: 15.0/255, green: 116.0/255, blue: 188.0/255, alpha: 1.0), for: .selected);
    }
    
    func editProductView(){
        performSegue(withIdentifier: "editProductView", sender: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        let product = self.product
        if segue.identifier == "editProductView" {
            if let destinationVC = segue.destination as? EditProductViewController {
                destinationVC.product = product;
            }
        }
    }
}
extension DetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.product != nil){
            return 6;
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCellTableViewCell", for: indexPath) as! DetailCellTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.nameLbl.text = "Tên";
            cell.contentLbl.text = self.product?.name;
        case 1:
            cell.nameLbl.text = "Giá bán";
            cell.contentLbl.text = "\(self.product?.cost ?? "--") 🇻🇳 ";
        case 2:
            cell.nameLbl.text = "Mô tả";
            cell.contentLbl.text = self.product?.description;
        case 3:
            cell.nameLbl.text = "Thành phần";
            cell.contentLbl.text = self.product?.ingredient;
        case 4:
            cell.nameLbl.text = "Cách sử dụng";
            cell.contentLbl.text = self.product?.uses;
        case 5:
            cell.nameLbl.text = "Barcode";
            cell.contentLbl.text = self.product?.barcode;
        default:
            cell.nameLbl.text = "None";
            cell.contentLbl.text = "None";
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        
    }
}

extension DetailsViewController:FSPagerViewDataSource,FSPagerViewDelegate {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return (product?.previews.count)!;
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index);
        cell.imageView?.clipsToBounds = true;
        
        let img = product?.previews[index]
        if !(img!.isEmpty) {
            cell.imageView!.sd_setImage(with: URL.init(string: img!), placeholderImage: UIImage.init(named: "logo"), options: SDWebImageOptions.progressiveLoad, completed: nil);
        }
        cell.imageView?.contentMode = .scaleAspectFill;
        return cell;
    }
    
    func pagerView(_ pagerView: FSPagerView, didHighlightItemAt index: Int) {
        self.pageControl?.currentPage = index;
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        self.pageControl?.currentPage = index;
        pagerView.deselectItem(at: index, animated: true);
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int){
        self.pageControl?.currentPage = index;
    }
}
