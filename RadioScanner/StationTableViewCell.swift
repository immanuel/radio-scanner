//
//  StationTableViewCell.swift
//  RadioScanner
//
//  Created by Immanuel Thomas on 9/3/16.
//  Copyright © 2016 Immanuel Thomas. All rights reserved.
//

import UIKit

class StationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var StationImage: UIImageView!
    @IBOutlet weak var SongName: UILabel!
    @IBOutlet weak var SongArtist: UILabel!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
