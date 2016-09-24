//
//  StationTableViewController.swift
//  RadioScanner
//
//  Created by Immanuel Thomas on 9/3/16.
//  Copyright © 2016 Immanuel Thomas. All rights reserved.
//

import UIKit

class StationTableViewController: UITableViewController, SPTAuthViewDelegate {
    
    var spotifyState = 0;
    var selectedPlaylist :SPTPartialPlaylist?
    var stations = [Station]()
    var spotifySession: SPTSession?

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
        print("View did appear")
        //startSpotifyLogin()
        if selectedPlaylist != nil {
            print("We have a default playlist: \(selectedPlaylist?.name)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Station setup
    
    func loadStations(){
        
        //let station = Station(name: "", photo: UIImage(named:"")!, code:"")!
        let station1 = Station(name: "1077 The Bone", photo: UIImage(named: "ksan")!, code: "ksan")!
        let station2 = Station(name: "98.5 KFOX", photo: UIImage(named: "kufx")!, code:"kufx")!
        let station3 = Station(name: "Mix 106.5", photo: UIImage(named:"kezr")!, code:"kezr")!
        let station4 = Station(name: "KFOG", photo: UIImage(named:"kfog")!, code:"kfog")!
        let station5 = Station(name: "94.5 KBAY", photo: UIImage(named:"kbay")!, code:"kbay")!
        
        stations += [station1, station2, station3, station4, station5]
        
    }
    
    @IBAction func FetchAll(sender: AnyObject) {
        for stationIndex in 0..<stations.count{
            let indexPath = NSIndexPath(forRow: stationIndex, inSection: 0)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            
            if cell == nil {
                print("\(stationIndex) No animation")
                dispatch_async(dispatch_get_main_queue()) {
                    self.stations[stationIndex].fetchCurrentSongAndArtist()
                }
            }
            else {
                print("\(stationIndex) Animation ")
                let stationCell = cell as! StationTableViewCell
                stationCell.loadingSpinner.startAnimating()
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    (stationCell.SongName.text, stationCell.SongArtist.text) = self.stations[stationIndex].fetchCurrentSongAndArtist()
                    stationCell.loadingSpinner.stopAnimating()
                }
            }
        }
        
    }
    
    // MARK: - Spotify setup
    
    @IBAction func loginButtonClick(sender: AnyObject) {
        if(self.spotifyState == 0){
            let auth = SPTAuth.defaultInstance()
            auth.clientID        = "f3557a5d6af84c85964a2e82bf61ba7c"
            auth.redirectURL     = NSURL.init(string:"radiotuner://logincallback")
            auth.requestedScopes = [SPTAuthPlaylistModifyPrivateScope]
            
            let authvc = SPTAuthViewController.authenticationViewController()
            authvc.modalPresentationStyle   = UIModalPresentationStyle.OverFullScreen
            authvc.modalTransitionStyle     = UIModalTransitionStyle.CoverVertical
            authvc.delegate                 = self // Comment this line if you want to build right now
            
            self.modalPresentationStyle     = UIModalPresentationStyle.CurrentContext
            self.definesPresentationContext = true
            self.presentViewController(authvc, animated: true, completion: nil)
        }
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Login")
        loginButton.title = "Choose Playlist"
        self.spotifyState = 1
        print("Expires on \(session.expirationDate)")
        self.spotifySession = session
        
        SPTPlaylistList.playlistsForUserWithSession(session, callback: { (error, object) in
            if error == nil {
                print("Got it")
                let playlists = object as! SPTPlaylistList
                print(playlists.hasNextPage)
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("playlistView") as! PlaylistTableViewController
                
                for item in playlists.items{
                    let pl = item as! SPTPartialPlaylist
                    print(pl.name)
                    vc.playlists.append(pl)
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
                
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
            print("\(indexPath.row) Get animation")
            cell.loadingSpinner.startAnimating()
            
            dispatch_async(dispatch_get_main_queue()) {
                (cell.SongName.text, cell.SongArtist.text) = station.fetchCurrentSongAndArtist()
                cell.loadingSpinner.stopAnimating()
            }
        }
        (cell.SongName.text, cell.SongArtist.text) = currSong

        return cell
    }

}
