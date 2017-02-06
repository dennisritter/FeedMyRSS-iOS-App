//
//  RSSEntry.swift
//  FeedMyRSS
//
//  Created by Johannes Ebeling on 03.02.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//

import Foundation

struct RSSEntry {
    
    var title: String
    var description: String
    var link: String
    var pubDate: String
    
    init(){
        self.title = ""
        self.description = ""
        self.link = ""
        self.pubDate = ""
    }
}
