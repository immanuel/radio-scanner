//
//  PlaylistTableViewController.swift
//  RadioScanner
//
//  Created by Immanuel Thomas on 9/23/16.
//  Copyright © 2016 Immanuel Thomas. All rights reserved.
//

import UIKit

class PlaylistTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    var playlists = [SPTPartialPlaylist]()
    var selectedPlaylist : SPTPartialPlaylist?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        navigationController?.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? StationTableViewController {
            controller.selectedPlaylist = selectedPlaylist
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PlaylistTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell

        // Configure the cell...
        
        let playlist = playlists[indexPath.row]
        
        cell.PlaylistName.text = playlist.name
        
        
        // TODO: Checkmark the current selected playlist
        /*
        if (some condition to initially checkmark a row)
        cell.accessoryType = .Checkmark
        tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.Bottom)
    } else {
    cell.accessoryType = .None
    }
        */

        return cell
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .None
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            cell.accessoryType = .Checkmark
            selectedPlaylist = playlists[indexPath.row]
            
        }
    }

}
