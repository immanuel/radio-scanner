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
    @IBOutlet weak var addToPlaylistButton: UIButton!
    
    @IBAction func addToPlaylist(sender: AnyObject) {
        
        let searchQuery = "track:\(SongName.text!) artist:\(SongArtist.text!)"
        
        SPTSearch.performSearchWithQuery(searchQuery, queryType: SPTSearchQueryType.QueryTypeTrack, accessToken: nil, callback: { (error, object) in
            if error == nil {
                let result = object as! SPTListPage
                
                if result.items != nil{
                
                    let track = result.items[0] as! SPTPartialTrack
                    
                    var artist = ""
                    for i in track.artists{
                        let a = i as! SPTPartialArtist
                        artist += a.name
                    }
                    print("\(track.name) by \(artist), on \(track.album.name)")
                }
                else{
                    print("No matching track found")
                }
            }
        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
