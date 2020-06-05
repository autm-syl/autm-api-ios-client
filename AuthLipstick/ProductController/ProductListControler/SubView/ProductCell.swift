//
//  ProductCell.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/5/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
