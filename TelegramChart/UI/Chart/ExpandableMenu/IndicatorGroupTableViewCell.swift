//
//  IndicatorGroupTableViewCell.swift
//  Protrader 3
//
//  Created by Yuriy on 27/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class IndicatorGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var arrow: UIImageView!
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
