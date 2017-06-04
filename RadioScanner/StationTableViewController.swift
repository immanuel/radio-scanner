//
//  StationTableViewController.swift
//  RadioScanner
//
//  Created by Immanuel Thomas on 9/3/16.
//  Copyright © 2016 Immanuel Thomas. All rights reserved.
//

import UIKit

class StationTableViewController: UITableViewController, SPTAuthViewDelegate {
    
    // TODO: Change state to enum
    var spotifyState = 0;
    
    var selectedPlaylist :SPTPartialPlaylist?
    var selectedFullPlaylist :SPTPlaylistSnapshot?
    var stations = [Station]()
    var spotifySession: SPTSession?
    
    var playlistViewController :PlaylistTableViewController?

    @IBOutlet weak var loginButton: UIBarButtonItem!

    // MARK: - Controller events
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // TODO: Make the initial load async or add a loading screen
        loadStations()
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if selectedPlaylist != nil {
            if spotifyState == 1 {spotifyState = 2}
            
            SPTPlaylistSnapshot.playlistWithURI(selectedPlaylist?.uri, accessToken: spotifySession?.accessToken, callback: {(error, object) in
                if error == nil{
                    // TODO: Don't display add to playlist if the playlist call fails
                    self.selectedFullPlaylist = object as? SPTPlaylistSnapshot
                }
            })
            
            for stationIndex in 0..<stations.count{
                let indexPath = NSIndexPath(forRow: stationIndex, inSection: 0)
                let cell = self.tableView.cellForRowAtIndexPath(indexPath)
                
                if cell != nil {
                    let stationCell = cell as! StationTableViewCell
                    stationCell.addToPlaylistButton.hidden = false
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Station setup
    func loadStations(){
        
        //let station = Station(name: "", photo: UIImage(named:"")!, code:"")!
        let station1 = Station(
            name: "1077 The Bone",
            photo: UIImage(named: "ksan")!,
            url: "http://ksan.tunegenie.com",
            artistXPath: "//div[contains(@class, 'hidden-on-open')]//div[@class='left']/div[2]",
            songXPath: "(//div[contains(@class, 'hidden-on-open')]//div[@class='song'])[1]")!
        let station2 = Station(
            name: "98.5 KFOX",
            photo: UIImage(named: "kufx")!,
            url:"http://kufx.tunegenie.com",
            artistXPath: "//div[contains(@class, 'hidden-on-open')]//div[@class='left']/div[2]",
            songXPath: "(//div[contains(@class, 'hidden-on-open')]//div[@class='song'])[1]")!
        let station3 = Station(
            name: "Mix 106.5",
            photo: UIImage(named:"kezr")!,
            url:"http://np.tritondigital.com/public/nowplaying?mountName=KEZRFMAAC&numberToFetch=1&eventType=track",
            artistXPath: "//property[@name='track_artist_name']",
            songXPath: "//property[@name='cue_title']")!
        let station4 = Station(
            name: "KFOG",
            photo: UIImage(named:"kfog")!,
            url:"http://kfog.tunegenie.com",
            artistXPath: "//div[contains(@class, 'hidden-on-open')]//div[@class='left']/div[2]",
            songXPath: "(//div[contains(@class, 'hidden-on-open')]//div[@class='song'])[1]")!
        let station5 = Station(
            name: "94.5 KBAY",
            photo: UIImage(named:"kbay")!,
            url:"http://np.tritondigital.com/public/nowplaying?mountName=KBAYFMAAC&numberToFetch=1&eventType=track",
            artistXPath: "//property[@name='track_artist_name']",
            songXPath: "//property[@name='cue_title']")!
        
        stations += [station1, station2, station3, station4, station5]
        
    }
    
    @IBAction func FetchAll(sender: AnyObject) {
        for stationIndex in 0..<stations.count{
            let indexPath = NSIndexPath(forRow: stationIndex, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            
            if cell == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.stations[stationIndex].fetchCurrentSongAndArtist()
                }
            }
            else {
                let stationCell = cell as! StationTableViewCell
                stationCell.loadingSpinner.startAnimating()
                stationCell.addToPlaylistButton.hidden = true
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    (stationCell.SongName.text, stationCell.SongArtist.text) = self.stations[stationIndex].fetchCurrentSongAndArtist()
                    stationCell.loadingSpinner.stopAnimating()
                    if self.spotifyState == 2 { stationCell.addToPlaylistButton.hidden = false}
                }
            }
        }
        
    }
    
    // MARK: - Spotify setup
    
    @IBAction func loginButtonClick(sender: AnyObject) {
        if(self.spotifyState == 0){
            
            // TODO: Doublecheck auth workflow  
            let auth = SPTAuth.defaultInstance()
            auth.clientID        = "f3557a5d6af84c85964a2e82bf61ba7c"
            auth.redirectURL     = NSURL.init(string:"radiotuner://logincallback")
            auth.requestedScopes = [SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPrivateScope, SPTAuthPlaylistModifyPublicScope]
            
            let authvc = SPTAuthViewController.authenticationViewController()
            authvc.modalPresentationStyle   = UIModalPresentationStyle.OverFullScreen
            authvc.modalTransitionStyle     = UIModalTransitionStyle.CoverVertical
            authvc.delegate                 = self // Comment this line if you want to build right now
            
            self.modalPresentationStyle     = UIModalPresentationStyle.CurrentContext
            self.definesPresentationContext = true
            self.presentViewController(authvc, animated: true, completion: nil)
        }
        else {
            self.navigationController?.pushViewController(self.playlistViewController!, animated: true)
        }
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {

        loginButton.title = "Select Playlist"
        self.spotifyState = 1
        
        // TODO: Get new token if expired
        self.spotifySession = session
        
        SPTPlaylistList.playlistsForUser(session.canonicalUsername, withAccessToken: session.accessToken, callback: { (error, object) in
                if error == nil {
                let playlists = object as! SPTPlaylistList
                
                // TODO: Handle multilpe pages of playlists
                // print(playlists.hasNextPage)
                
                self.playlistViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("playlistView") as! PlaylistTableViewController)
                
                // TODO: Handle no playlists
                for item in playlists.items{
                    let pl = item as! SPTPartialPlaylist
                    self.playlistViewController!.playlists.append(pl)
                }
                
                self.playlistViewController!.selectedPlaylist = self.selectedPlaylist
                
                self.navigationController?.pushViewController(self.playlistViewController!, animated: true)
                
            }
        })
        
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("Fail to login")
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("Cancel login")
    }

    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "StationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! StationTableViewCell

        // Configure the cell...
        
        let station = stations[indexPath.row]
        
        cell.StationImage.image = station.photo
        let currSong = station.getCurrentSongAndArtist()
        if currSong.artist == nil {
            cell.loadingSpinner.startAnimating()
            cell.addToPlaylistButton.hidden = true
            
            dispatch_async(dispatch_get_main_queue()) {
                (cell.SongName.text, cell.SongArtist.text) = station.fetchCurrentSongAndArtist()
                cell.loadingSpinner.stopAnimating()
                if self.spotifyState == 2 { cell.addToPlaylistButton.hidden = false}
            }
        }
        else {
            if spotifyState == 2 { cell.addToPlaylistButton.hidden = false}
            else {cell.addToPlaylistButton.hidden = true}
        }
        
        (cell.SongName.text, cell.SongArtist.text) = currSong
        cell.parentTableViewController = self

        return cell
    }

}
