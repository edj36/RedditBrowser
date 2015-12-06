//
//  ViewController.swift
//  Reddit
//
//  Created by Eric Johnson  on 9/26/15.
//  Copyright (c) 2015 Eric Johnson . All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBAction func frontPage(sender: AnyObject) {
        let vc = SubRedditViewController()
        vc.sub = "/"
        navigationController?.pushViewController(vc, animated: true)
    
    }

    var list = []
    var screenWidth:CGFloat = 0.0
    var screenHeight:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var screenSize:CGRect = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        self.title = "Choose a subreddit"
        getReddit("https://www.reddit.com/subreddits/.json")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 54
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
       
            let redditEntry : NSMutableDictionary = self.list[indexPath.row] as! NSMutableDictionary
            cell.textLabel!.text = redditEntry["data"]!["title"] as? String
            cell.detailTextLabel!.text = redditEntry["data"]!["author"] as? String
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = SubRedditViewController()
        let redditEntry : NSMutableDictionary = self.list[indexPath.row] as! NSMutableDictionary
        vc.sub = redditEntry["data"]!["url"] as? String
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getReddit(subReddit: String) {
        let mySession = NSURLSession.sharedSession()
        let url: NSURL = NSURL(string: subReddit)!
        let task = mySession.dataTaskWithURL(url, completionHandler : {data, response, error -> Void in
            var err: NSError?
            var redditJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            let results: NSArray = redditJSON["data"]!["children"] as! NSArray
            dispatch_async(dispatch_get_main_queue(), {
                self.list = results
                self.tableView.reloadData()
                })
            })
            task.resume()
    }


}

