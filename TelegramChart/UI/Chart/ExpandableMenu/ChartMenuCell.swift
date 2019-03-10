//
//  ChartMenuCell.swift
//  Protrader 3
//
//  Created by Yuriy on 21/11/2017.
//  Copyright © 2017 PFSoft. All rights reserved.
//

import UIKit

class ChartMenuCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.textColor = Colors.instance.chart_menuButtonColor
        label.highlightedTextColor = Colors.instance.chart_menuButtonActiveColor
        // Initialization code
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
