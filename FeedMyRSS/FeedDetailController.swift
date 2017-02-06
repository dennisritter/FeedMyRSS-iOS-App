//
//  FeedDetailController.swift
//  FeedMyRSS
//
//  Created by Dennis Ritter on 29.01.17.
//  Copyright © 2017 Johannes Ebeling. All rights reserved.
//
import UIKit

class FeedDetailController: UIViewController, UITableViewDataSource, UITableViewDelegate, XMLParserDelegate {
    
    var selectedFeed: UserFeed?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var suscribeSwitch: UISwitch!
    
    let defaults = UserDefaults.standard
    
    // xml parser
    var myParser: XMLParser = XMLParser()
    
    // rss records
    var rssEntryList : [RSSEntry] = []
    var rssEntry : RSSEntry?
    var selectedEntry: IndexPath = [0,0]
    var isTagFound = [ "item": false , "title":false, "pubDate": false ,"link":false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (selectedFeed?.feedId.hasPrefix("feed/"))! {
            selectedFeed?.feedId.removeSubrange((selectedFeed?.feedId.range(of: "feed/"))!)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let userFeeds = defaults.dictionary(forKey: "userFeeds") {
            if userFeeds.keys.contains((selectedFeed?.feedId)!) {
                suscribeSwitch.isOn = true
            } else {
                suscribeSwitch.isOn = false
            }
        } else {
            suscribeSwitch.isOn = false
        }
        if let feed = selectedFeed {
            titleLabel.text = feed.title
            titleLabel.adjustsFontSizeToFitWidth = true
            do {
                if let iconUrl = selectedFeed?.visualURL {
                    imageView.image = UIImage(data: try Data(contentsOf: URL(string: iconUrl)!))
                }
            }
            catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // load Rss data and parse
        if self.rssEntryList.isEmpty {
            self.loadRSSData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //  MARK: - TableViewDelegate / TableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rssEntryList.count
    }
    
    // return cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // collect reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        // find record for current cell
        let thisRecord : RSSEntry  = self.rssEntryList[indexPath.row]
        
        // set value for main title and detail tect
        cell.textLabel?.text = thisRecord.title
        cell.detailTextLabel?.text = thisRecord.pubDate
        
        // return cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedEntry = indexPath
        self.performSegue(withIdentifier: "showWebsite", sender: self)
    }
    
    // load rss and parse it
    private func loadRSSData(){
        
        if let rssURL = URL(string: (selectedFeed?.feedId)!) {
            
            // fetch rss content from url
            self.myParser = XMLParser(contentsOf: rssURL)!
            
            // set parser delegate
            self.myParser.delegate = self
            self.myParser.shouldResolveExternalEntities = false
            
            // start parsing
            self.myParser.parse()
        }
        
    }
    
    // MARK: - NSXML Parse delegate function
    // start parsing document
    func parserDidStartDocument(_ parser: XMLParser) {
        // start parsing
    }
    
    // element start detected
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "item" || elementName == "entry" {
            self.isTagFound["item"] = true
            self.rssEntry = RSSEntry()
        }else if elementName == "title" {
            self.isTagFound["title"] = true
        }else if elementName == "link" || elementName == "id"{
            self.isTagFound["link"] = true
        }else if elementName == "pubDate" {
            self.isTagFound["pubDate"] = true
        }
    }
    
    // characters received for some element
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if isTagFound["title"] == true {
            self.rssEntry?.title += string
        }else if isTagFound["link"] == true {
            self.rssEntry?.link += string
        }else if isTagFound["pubDate"] == true {
            self.rssEntry?.pubDate += string
        }
    }
    
    // element end detected
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" || elementName == "entry"{
            self.isTagFound["item"] = false
            self.rssEntryList.append(self.rssEntry!)
            
        }else if elementName == "title" {
            self.isTagFound["title"] = false
            
        }else if elementName == "link" || elementName == "id" {
            self.isTagFound["link"] = false
            
        }else if elementName == "pubDate" {
            self.isTagFound["pubDate"] = false
        }
    }
    
    // end parsing document
    func parserDidEndDocument(_ parser: XMLParser) {
        //reload table view
        self.tableView.reloadData()
    }
    
    // if any error detected while parsing.
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
    }
    
    //  MARK: - User interaction
    
    @IBAction func goToHostWebsite(_ sender: UIButton) {
        performSegue(withIdentifier: "showHostWebsite", sender: self)
    }
    @IBAction func subscribeToFeed(_ sender: UISwitch) {
        if var dict = defaults.dictionary(forKey: "userFeeds") {
            if sender.isOn && (dict.keys.contains((selectedFeed?.feedId)!)) == false {
                let _ = dict.updateValue([(selectedFeed?.title)!, (selectedFeed?.visualURL)!, (selectedFeed?.website)!], forKey: (selectedFeed?.feedId)!)
            } else {
                let _ = dict.removeValue(forKey: (selectedFeed?.feedId)!)
            }
            defaults.set(dict, forKey: "userFeeds")
        } else {
            UserDefaults.standard.set([(selectedFeed?.feedId)!:[(selectedFeed?.title)!, (selectedFeed?.visualURL)!, (selectedFeed?.website)!]], forKey: "userFeeds")
        }
    }
    
    //  MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showWebsite" {
            // create destination view controller
            let destVc = segue.destination as! WebViewController
            // set link value for destination view controller
            destVc.link = self.rssEntryList[selectedEntry[1]].link
        } else if segue.identifier == "showHostWebsite" {
            let destVc = segue.destination as! WebViewController
            destVc.link = selectedFeed?.website
        }
    }
}
