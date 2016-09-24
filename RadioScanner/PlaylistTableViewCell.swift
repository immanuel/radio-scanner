//
//  PlaylistTableViewCell.swift
//  RadioScanner
//
//  Created by Immanuel Thomas on 9/23/16.
//  Copyright © 2016 Immanuel Thomas. All rights reserved.
//

import UIKit

class PlaylistTableViewCell: UITableViewCell {

    
    @IBOutlet weak var PlaylistName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
