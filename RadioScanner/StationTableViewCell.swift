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
    
    weak var parentTableViewController :StationTableViewController?
    
    @IBAction func addToPlaylist(sender: AnyObject) {
        
        addToPlaylistButton.hidden = true
        loadingSpinner.startAnimating()
        
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
                    
                    print("Adding '\(track.name)' by \(artist) to '\(self.parentTableViewController?.selectedFullPlaylist?.name)'")
                    
                    var tracks = [SPTPartialTrack]()
                    tracks.append(track)

                    self.parentTableViewController?.selectedFullPlaylist!.addTracksToPlaylist(tracks, withSession: self.parentTableViewController?.spotifySession!, callback: {(error) in
                        if error != nil{
                            print("Error addding track to playlist")
                            print(error)
                            
                        } else {
                            print("Added track to playlist")
                        }
                        self.loadingSpinner.stopAnimating()
                        self.addToPlaylistButton.hidden = false
                    })
                }
                else{
                    print("No matching track found")
                    self.loadingSpinner.stopAnimating()
                    self.addToPlaylistButton.hidden = false
                }
            }
            else{
                print("Error searching for track")
                print(error)
                self.loadingSpinner.stopAnimating()
                self.addToPlaylistButton.hidden = false
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
