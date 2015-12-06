//
//  SubRedditViewController.swift
//  Reddit
//
//  Created by Eric Johnson  on 9/28/15.
//  Copyright (c) 2015 Eric Johnson . All rights reserved.
//

import UIKit

class SubRedditViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    var list = []
    var sub: String!
    var tableView : UITableView?
    var screenWidth:CGFloat = 0.0
    var screenHeight:CGFloat = 0.0
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var screenSize:CGRect = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        if let subReddit = sub {
            getSubReddit("https://www.reddit.com" + sub + ".json")
            if (sub == "/") {
                self.title = "Front Page"
            } else {
                self.title = sub
            }
        }
        
        self.tableView = UITableView(frame: CGRectMake(0, 0, screenWidth, screenHeight-44), style: UITableViewStyle.Plain)
        self.tableView!.rowHeight = 72
        self.tableView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        self.tableView!.registerClass(ListTableViewCell.self, forCellReuseIdentifier: "cell")
        let nib = UINib(nibName: "ListTableViewCell", bundle: nil)
        self.tableView!.registerNib(nib, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView!)

        // buttons
        let seconds = 0.4
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            var hotButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            hotButton.frame = CGRectMake(0, self.screenHeight-44, self.screenWidth/3, 44)
            hotButton.setTitle("Hot", forState: UIControlState.Normal)
            hotButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            hotButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            hotButton.backgroundColor = UIColor.whiteColor()
            hotButton.addTarget(self, action: "hotButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            hotButton.layer.borderWidth = 0.5
            hotButton.layer.borderColor = UIColor.blackColor().CGColor
            self.view.addSubview(hotButton)
            
            var newButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            newButton.frame = CGRectMake(self.screenWidth/3, self.screenHeight-44, self.screenWidth/3, 44)
            newButton.setTitle("New", forState: UIControlState.Normal)
            newButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            newButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            newButton.backgroundColor = UIColor.whiteColor()
            newButton.addTarget(self, action: "newButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            newButton.layer.borderWidth = 0.5
            newButton.layer.borderColor = UIColor.blackColor().CGColor
            self.view.addSubview(newButton)
            
            var conButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            conButton.frame = CGRectMake((2*self.screenWidth)/3, self.screenHeight-44, self.screenWidth/3, 44)
            conButton.setTitle("Controversial", forState: UIControlState.Normal)
            conButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
            conButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
            conButton.backgroundColor = UIColor.whiteColor()
            conButton.addTarget(self, action: "conButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            conButton.layer.borderWidth = 0.5
            conButton.layer.borderColor = UIColor.blackColor().CGColor
            self.view.addSubview(conButton)
        })
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ListTableViewCell
        let redditEntry : NSMutableDictionary = self.list[indexPath.row] as! NSMutableDictionary
        cell.titleLabel.text = redditEntry["data"]!["title"] as? String
        cell.titleLabel.numberOfLines = 0
        cell.authorLabel.text = redditEntry["data"]!["author"] as? String
        cell.numComments.text = ((redditEntry["data"]!["num_comments"] as? Int)?.description)! + " comments"
        cell.scoreLabel.text = (redditEntry["data"]!["score"] as? Int)?.description
        
        if cell.thumbnail.image != nil {
            cell.thumbnail.image = cell.thumbnail.image
        } else {
            var imgString: String = (redditEntry["data"]!["thumbnail"] as? String)!
            let imgURL = NSURL(string: imgString)
            if let dataForImage = NSData(contentsOfURL: imgURL!) {
                if let image = UIImage(data: dataForImage) {
                    cell.thumbnail.image = image
                } else {
                    var pic: UIImage = UIImage(named: "icon")!
                    cell.thumbnail.image = pic
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = DetailViewController()
        let reddit : NSMutableDictionary = self.list[indexPath.row] as! NSMutableDictionary
        vc.url = reddit["data"]!["url"] as? String
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func getSubReddit(subReddit: String) {
        let mySession = NSURLSession.sharedSession()
        let url: NSURL = NSURL(string: subReddit)!
        let task = mySession.dataTaskWithURL(url, completionHandler : {data, response, error -> Void in
            var err: NSError?
            var redditJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSDictionary
            let results: NSArray = redditJSON["data"]!["children"] as! NSArray
            dispatch_async(dispatch_get_main_queue(), {
                self.list = results
                self.tableView!.reloadData()
            })
        })
        task.resume()
    }
    
    
    /* Puts "hot" content in tableView  */
    func hotButtonAction(sender:UIButton!) {
        getSubReddit("https://www.reddit.com" + sub + ".json")
    }
    
    /* Puts "new" content in tableView  */
    func newButtonAction(sender:UIButton!) {
        getSubReddit("https://www.reddit.com" + sub + "new/" + ".json")
    }
    
    /* Puts "controversial" content in tableView */
    func conButtonAction(sender:UIButton!) {
        getSubReddit("https://www.reddit.com" + sub + "controversial/" + ".json")
    }
    
    func refresh(sender:AnyObject) {
        getSubReddit("https://www.reddit.com" + sub + ".json")
        self.refreshControl.endRefreshing()
    }
}



