//
//  ActiveIndicatorViewCellTableViewCell.swift
//  Protrader 3
//
//  Created by Yuriy on 01/12/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class ActiveIndicatorViewCellTableViewCell: UITableViewCell {

    weak var indicatorObject:IndicatorObject?
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var label: BaseLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
   
    @IBAction func closeButtonAction(_ sender: Any) {
        indicatorObject?.closeClosure?()
    }
    @IBAction func editButtonAction(_ sender: Any) {
        indicatorObject?.editClosure?()
    }
}
