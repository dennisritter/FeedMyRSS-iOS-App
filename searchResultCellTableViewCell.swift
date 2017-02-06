//
//  searchResultCellTableViewCell.swift
//  FeedMyRSS
//
//  Created by Dennis Ritter on 29.01.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
