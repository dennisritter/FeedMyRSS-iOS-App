//
//  UserFeed.swift
//  FeedMyRSS
//
//  Created by Johannes Ebeling on 03.02.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//

import Foundation

struct UserFeed{
    var feedId: String
    var title: String
    var visualURL: String
    var website: String
    
    
    init() {
        feedId = " "
        title = " "
        visualURL = " "
        website = " "
    }
    
    init(feedId: String, title: String, visualURL: String, website: String) {
        self.init()
        self.feedId = feedId
        self.title = title
        self.visualURL = visualURL
        self.website = website
    }
}
