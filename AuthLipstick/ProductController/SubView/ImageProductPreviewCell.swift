//
//  ImageProductPreviewCell.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/4/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit

protocol ImageProductPreviewCellDelegate: class {
    func didRemoveItem(item:ImageProductPreviewCell);
    func didAddMoreItem();
}

class ImageProductPreviewCell: UICollectionViewCell {
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    
    weak var delegate:ImageProductPreviewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addBtnClicked(_ sender: Any) {
        self.delegate?.didAddMoreItem()
    }
    @IBAction func removeBtnClicked(_ sender: Any) {
        self.delegate?.didRemoveItem(item: self)
    }
    
    public func nonImage(isImage:Bool){
        if (isImage){
            self.removeBtn.isHidden = true;
            self.addBtn.isHidden = false;
        }else {
            self.removeBtn.isHidden = false;
            self.addBtn.isHidden = true;
        }
    }
    
    override func prepareForReuse() {
        self.imgThumb.image = nil;
    }
}
