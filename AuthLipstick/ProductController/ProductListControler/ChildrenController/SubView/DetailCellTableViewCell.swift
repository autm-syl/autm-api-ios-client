//
//  DetailCellTableViewCell.swift
//  AuthLipstick
//
//  Created by Sylvanas on 11/5/19.
//  Copyright © 2019 Sylvanas. All rights reserved.
//

import UIKit

class DetailCellTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
