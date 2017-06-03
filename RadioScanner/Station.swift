//
//  Station.swift
//  RadioScanner
//
//  Created by Immanuel Thomas on 9/3/16.
//  Copyright © 2016 Immanuel Thomas. All rights reserved.
//

import UIKit

class Station {
    
    var name: String
    var url: String
    var artistXPath: String
    var songXPath: String
    var currentSong: String?
    var currentArtist: String?
    var photo: UIImage

    init?(name: String, photo: UIImage, url: String, artistXPath: String, songXPath: String){
        self.name = name
        self.photo = photo
        self.url = url
        self.artistXPath = artistXPath
        self.songXPath = songXPath
        
        if (name.isEmpty || url.isEmpty || artistXPath.isEmpty || songXPath.isEmpty){
            return nil
        }
    }
    
    func fetchCurrentSongAndArtist() -> (song: String?, artist: String?){
        
        var myHTMLString:String = ""
        guard let myURL = NSURL(string: url) else {
            print("Error: \(url) doesn't seem to be a valid URL")
            return (self.currentSong, self.currentArtist)
        }
        do {
            myHTMLString = try String(contentsOfURL: myURL)
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        if let doc = XML(xml: myHTMLString, encoding: NSUTF8StringEncoding) {
            
            let songElement = doc.xpath(songXPath)
            let artistElement = doc.xpath(artistXPath)
            
            switch songElement {
            case .None:
                print("Error - parsing failed")
            default:
                switch artistElement{
                    case .None:
                        print("Error - parsing failed")
                    default:
                        self.currentSong =  songElement[0].content
                        self.currentArtist = artistElement[0].content
                }
            }
        }
        return (self.currentSong, self.currentArtist)

    }
    
    func getCurrentSongAndArtist() ->(song: String?, artist: String?) {
        return (self.currentSong, self.currentArtist)
    }
    
}
