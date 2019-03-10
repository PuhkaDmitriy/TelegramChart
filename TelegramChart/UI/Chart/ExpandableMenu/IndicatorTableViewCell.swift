//
//  IndicatorTableViewCell.swift
//  Protrader 3
//
//  Created by Yuriy on 25/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class IndicatorTableViewCell: UITableViewCell {

    @IBOutlet weak var plus: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
