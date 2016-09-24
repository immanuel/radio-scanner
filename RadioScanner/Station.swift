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
    var code: String
    var currentSong: String?
    var currentArtist: String?
    var photo: UIImage

    init?(name: String, photo: UIImage, code: String){
        self.name = name
        self.photo = photo
        self.code = code
        
        if (name.isEmpty || code.isEmpty){
            return nil
        }
    }
    
    func fetchCurrentSongAndArtist() -> (song: String?, artist: String?){
        
        let myURLString = "http://\(self.code).tunegenie.com"
        var myHTMLString:String = ""
        
        guard let myURL = NSURL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return (self.currentSong, self.currentArtist)
        }
        
        do {
            myHTMLString = try String(contentsOfURL: myURL)
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        if let doc = HTML(html: myHTMLString, encoding: NSUTF8StringEncoding) {
            
            let songElement = doc.xpath("(//div[contains(@class, 'hidden-on-open')]//div[@class='song'])[1]")
            let artistElement = doc.xpath("//div[contains(@class, 'hidden-on-open')]//div[@class='left']/div[2]")
            
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
