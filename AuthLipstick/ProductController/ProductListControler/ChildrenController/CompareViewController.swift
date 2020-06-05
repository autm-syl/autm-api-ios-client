//
//  CompareViewController.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit
import autmsheetview
import SVProgressHUD
import SDWebImage

class CompareViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    @IBOutlet weak var spreadSheetView: SpreadsheetView!
    @IBOutlet weak var listCompareView: UIView!
    @IBOutlet weak var tableListCompare: UITableView!
    @IBOutlet weak var titleCompare: UILabel!
    @IBOutlet weak var showBtn: UIButton!
//    let dates = ["7/10/2017", "7/11/2017", "7/12/2017", "7/13/2017", "7/14/2017", "7/15/2017", "7/16/2017"]
//    let days = ["MONDAY", "TUESDAY", "WEDNSDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"]
//    let dayColors = [UIColor(red: 0.918, green: 0.224, blue: 0.153, alpha: 1),
//                     UIColor(red: 0.106, green: 0.541, blue: 0.827, alpha: 1),
//                     UIColor(red: 0.200, green: 0.620, blue: 0.565, alpha: 1),
//                     UIColor(red: 0.953, green: 0.498, blue: 0.098, alpha: 1),
//                     UIColor(red: 0.400, green: 0.584, blue: 0.141, alpha: 1),
//                     UIColor(red: 0.835, green: 0.655, blue: 0.051, alpha: 1),
//                     UIColor(red: 0.153, green: 0.569, blue: 0.835, alpha: 1)]
//    let hours = ["6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM", "12:00 AM", "1:00 PM", "2:00 PM",
//                 "3:00 PM", "4:00 PM", "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM", "10:00 PM", "11:00 PM"]
    let evenRowColor = UIColor(red: 0.914, green: 0.914, blue: 0.906, alpha: 1)
    let oddRowColor: UIColor = UIColor(red: 4/255.0, green: 97/255.0, blue: 78/255.0, alpha: 1)
//    let data = [
//        ["", "", "Take medicine", "", "", "", "", "", "", "", "", "", "", "Movie with family", "", "", "", "", "", ""],
//        ["Leave for cabin", "", "", "", "", "Lunch with Tim", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
//        ["", "", "", "", "Downtown parade", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
//        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "Fireworks show", "", "", ""],
//        ["", "", "", "", "", "Family BBQ", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
//        ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""],
//        ["", "", "", "", "", "", "", "", "", "", "", "", "", "Return home", "", "", "", "", "", ""]
//    ]
    
    var top_name:[String] = [] // as dates
    var left_contain = ["Giá bán", "Mô tả", "Thành phần", "Cách sử dụng"];
    
    var lst_show_product:[Product] = []
    var datas:[[String]] = [];
    
    func createData(){
        lst_show_product.forEach { (item) in
            //
            top_name.append(item.name)
        }
        //
        
        lst_show_product.forEach { (item) in
            //
            var row_data:[String] = []
            for i in 0...3 {
                switch i {
                case 0:
                    row_data.append(item.cost);
                case 1:
                    row_data.append(item.description);
                case 2:
                    row_data.append(item.ingredient);
                case 3:
                    row_data.append(item.uses);
                default:
                    row_data.append("");
                }
            }
            
            datas.append(row_data);
        }
        
        self.settingSheetView();
        //
        spreadSheetView.flashScrollIndicators()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
//        if (self.isMovingFromParent) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    func canRotate() -> Void {}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setting table view
        tableListCompare.delegate = self;
        tableListCompare.dataSource = self;
        tableListCompare.separatorColor = UIColor.clear;
        tableListCompare.register(UINib.init(nibName: "ProductCell", bundle: Bundle(for: ProductCell.self)), forCellReuseIdentifier: "ProductCell")
        
        lst_show_product = Globalvariables.shareInstance.listCompare;
        
        self.tableListCompare.reloadData();
        if (lst_show_product.count == 0){
            self.titleCompare.text = "Chưa có sản phẩm nào được thêm vào so sánh";
        } else {
            self.titleCompare.text = "Danh sách so sánh";
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func settingSheetView(){
        // Do any additional setup after loading the view.
        self.spreadSheetView.dataSource = self
        self.spreadSheetView.delegate = self

        spreadSheetView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)

        spreadSheetView.intercellSpacing = CGSize(width: 4, height: 1)
        spreadSheetView.gridStyle = .none

        spreadSheetView.register(DateCell.self, forCellWithReuseIdentifier: String(describing: DateCell.self))
        spreadSheetView.register(TimeTitleCell.self, forCellWithReuseIdentifier: String(describing: TimeTitleCell.self))
        spreadSheetView.register(TimeCell.self, forCellWithReuseIdentifier: String(describing: TimeCell.self))
        spreadSheetView.register(DayTitleCell.self, forCellWithReuseIdentifier: String(describing: DayTitleCell.self))
        spreadSheetView.register(ScheduleCell.self, forCellWithReuseIdentifier: String(describing: ScheduleCell.self))
    }
    
    @IBAction func showBtnClicked(_ sender: Any) {
        if (lst_show_product.count > 0) {
            self.createData();
            self.listCompareView.isHidden = true;
        }
    }
    @IBAction func backBtnClicked(_ sender: Any) {
         self.navigationController?.popViewController(animated: true);
    }
    
    // MARK: DataSource

    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + top_name.count
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + left_contain.count
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if case 0 = column {
            return 140
        } else {
            return 300
        }
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else if case 1 = row {
            return 30
        } else {
            return 240
        }
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case (1...(top_name.count + 1), 0) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: DateCell.self), for: indexPath) as! DateCell
            cell.label.text = top_name[indexPath.column - 1]
            return cell
        }  else if case (0, 0) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeTitleCell.self), for: indexPath) as! TimeTitleCell
            cell.label.text = "Lips"
            return cell
        } else if case (0, 1...(left_contain.count + 1)) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeCell.self), for: indexPath) as! TimeCell
            cell.label.text = left_contain[indexPath.row - 1]
            cell.backgroundColor = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
            return cell
        } else if case (1...(top_name.count + 1), 1...(left_contain.count + 1)) = (indexPath.column, indexPath.row) {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: ScheduleCell.self), for: indexPath) as! ScheduleCell
            let text = datas[indexPath.column - 1][indexPath.row - 1]
            if !text.isEmpty {
                cell.label.text = text
                let color = indexPath.column % 2 == 0 ? evenRowColor : oddRowColor
//                cell.label.textColor = color
//                cell.color = color.withAlphaComponent(0.2)
                cell.borders.top = .solid(width: 2, color: color)
                cell.borders.bottom = .solid(width: 2, color: color)
            } else {
                cell.label.text = nil
                cell.color = indexPath.row % 2 == 0 ? evenRowColor : oddRowColor
                cell.borders.top = .none
                cell.borders.bottom = .none
            }
            return cell
        }
        return nil
    }

    /// Delegate

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        print("Selected: (row: \(indexPath.row), column: \(indexPath.column))")
    }

}

extension CompareViewController: UITableViewDelegate, UITableViewDataSource {
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
        var cell:ProductCell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)  as! ProductCell;

        
        let item = self.lst_show_product[indexPath.row];
        var thumb:String = "";
        
        if (item.previews.count != 0){
            thumb = item.previews[0];
        }
        
        cell.nameLbl.text = item.name;
        cell.costLbl.text = item.cost;
        
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
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            // share item at indexPath
            self.lst_show_product.remove(at: indexPath.row)
            Globalvariables.shareInstance.removeToCompare(index: indexPath.row);
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            SVProgressHUD.showError(withStatus: "Khoá khỏi danh sách so sánh");
            SVProgressHUD.dismiss(withDelay: 2.0);
        }

        delete.backgroundColor = UIColor.red

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let product = self.lst_show_product[indexPath.row];
//        self.showDetailProduct(product: product);
    }
}
