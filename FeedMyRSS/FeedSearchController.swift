//
//  FeedSearchController.swift
//  FeedMyRSS
//
//  Created by Johannes Ebeling on 13.01.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//

import UIKit

typealias ServiceResponse = (JSON, NSError?) -> Void

class FeedSearchController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchResults: JSON = JSON.null
    var selectedResult: IndexPath = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        
        tableView.tableHeaderView = searchController.searchBar
    }
    
    //  MARK: - TableViewDelegate / TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows matches number of results..
        return self.searchResults["results"].arrayValue.count;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedResult = indexPath
        performSegue(withIdentifier: "showFeedDetails", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResult", for: indexPath) as! SearchResultCell
        
        let result = searchResults["results"][indexPath[1]]
        cell.label.text = result["title"].stringValue
        do {
            if let iconUrl = result["visualUrl"].string {
                cell.iconView.image = UIImage(data: try Data(contentsOf: URL(string: iconUrl)!))
            }
        }
        catch let error{
            print(error.localizedDescription)
        }
        return cell
    }
    
    func updateTableView(){
        self.tableView.reloadData();
    }
    
    //  MARK: - SearchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            self.newSearchQuery(searchString: searchBar.text!, onCompletion: {json, err in
                self.searchResults = json;
                DispatchQueue.main.async {
                    self.updateTableView()
                }
            })
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    //  MARK: - API Handling
    
    func createURLRequest(query: String) -> URL {
        let BASE_URL = "https://cloud.feedly.com/v3/search/feeds"
        let QUERY = "query=\(query)"
        let LOCALE = "locale=en"
        let COUNT = "count=20"
        let urlString = "\(BASE_URL)?\(QUERY)&\(LOCALE)&\(COUNT)&"
        
        return URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    }
    
    func newSearchQuery(searchString string: String, onCompletion: @escaping ServiceResponse) {
        let request = NSMutableURLRequest(url: createURLRequest(query: string))
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if let jsonData = data {
                let json: JSON = JSON(data: jsonData)
                onCompletion(json, error as NSError?)
            } else {
                onCompletion(JSON.null, error as NSError?)
            }
        })
        task.resume()
    }
    
    //  MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! FeedDetailController
        let feedJSON = searchResults["results"][selectedResult[1]]
        let feed = UserFeed(feedId: feedJSON["feedId"].stringValue,
                            title: feedJSON["title"].stringValue,
                            visualURL: feedJSON["visualUrl"].stringValue,
                            website: feedJSON["website"].stringValue)
        destination.selectedFeed = feed
    }
}
