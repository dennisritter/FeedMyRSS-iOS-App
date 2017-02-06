//
//  ViewController.swift
//  FeedMyRSS
//
//  Created by Johannes Ebeling on 13.01.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//

import UIKit

class MyFeedsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let defaults = UserDefaults.standard
    var userFeeds: [UserFeed] = []
    var selectedResult: IndexPath = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = defaults.dictionary(forKey: "userFeeds") as? [String:[String]] {
            self.userFeeds = []
            for feed in defaults.dictionary(forKey: "userFeeds") as! [String:[String]] {
                userFeeds.append(UserFeed(feedId: feed.key, title: feed.value[0], visualURL: feed.value[1], website: feed.value[2]))
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        self.definesPresentationContext = true
    }
    
    //  MARK: - TableViewDelegate / TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows matches number of results..
        return userFeeds.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedResult = indexPath
        performSegue(withIdentifier: "showMyFeedDetails", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! SearchResultCell
        
        if(userFeeds.isEmpty){
            return cell
        }
        
        let result = userFeeds[indexPath[1]]
        cell.label.text = result.title
        
        do {
            cell.iconView.image = UIImage(data: try Data(contentsOf: URL(string: result.visualURL)!))
        }
        catch let error{
            print(error.localizedDescription)
        }
        return cell
    }
    
    //  MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMyFeedDetails" {
            let destination = segue.destination as! FeedDetailController
            destination.selectedFeed = userFeeds[selectedResult[1]]
        }
    }
    
    @IBAction func rewindFromDetail(_ segue: UIStoryboardSegue) {
        
    }
}

