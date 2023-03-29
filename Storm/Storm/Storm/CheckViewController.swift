//
//  SecondViewController.swift
//  Storm
//
//  Created by Vagrant on 4/5/16.
//  Copyright © 2016 Storm. All rights reserved.
//

import UIKit


class userInfo {
    var id: String = ""
    var name: String = ""
    var department: String = ""
    var checkValue: String = ""
    var checkTime: String = ""
    var photoUrlPath: String = ""
    var deviceUrlPath: String = ""
}

class CheckViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellTableIdentifier = "CellTableIdentifier"
    
    let urlString: String = "http://www.acstorm.net/"
   
    var tableViewController = UITableViewController(style: .Plain)
    var tableView = UITableView()
    
    //@IBOutlet weak var tableView: UITableView!
    
    var member = [userInfo]()
    var refreshControl = UIRefreshControl()
    //var tableViewCell = UITableViewCell() //style: .Value1, reuseIdentifier: "cellTableIdentifier")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbar = self.tabBarController?.tabBar
        let navi = self.navigationController?.navigationBar
        navi!.topItem?.title = "체크상황"

        navi!.barTintColor = UIColor.orangeColor()
        navi!.tintColor = UIColor.whiteColor()
        navi!.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        tableView = tableViewController.tableView

        //tableViewController.ttableView = tableView
        
        tableView.delegate = self
        tableView.dataSource = self

        let naviBottom = navi!.frame.origin.y + navi!.frame.size.height
        let tabbarHeight = tabbar!.frame.size.height
        let tableViewHeight = self.view.frame.size.height - tabbarHeight - naviBottom
        //print("tableViewHeight :\( tableViewHeight)")
        
        tableView.frame = CGRectMake(0, naviBottom, self.view.bounds.width, tableViewHeight)
        //tableView.backgroundColor = UIColor.orangeColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellTableIdentifier)
        tableViewController.refreshControl = self.refreshControl
        
        self.refreshControl.addTarget(self, action: #selector(self.refresh), forControlEvents: UIControlEvents.ValueChanged)

        //self.view.addSubview(tableView)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.layoutSubviews()
    }
    
 /*
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabbar = self.tabBarController?.tabBar
        let navi = self.navigationController?.navigationBar
        navi!.topItem?.title = "체크상황"
        navi!.translucent = true
       
        stormMember = names
       
        
        let tableView = tableViewController.tableView
        tableView.delegate = self
        let naviBottom = navi!.frame.origin.y + navi!.frame.size.height
        let tabbarHeight = tabbar!.frame.size.height
        let tableViewHeight = self.view.frame.size.height - tabbarHeight - naviBottom
        print("tableViewHeight :\( tableViewHeight)")
        
        tableView.frame = CGRectMake(0, naviBottom, self.view.bounds.width, tableViewHeight)
        tableView.backgroundColor = UIColor.orangeColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellTableIdentifier)
        tableView.dataSource = self
    
    //self.view.backgroundColor = UIColor(red:89/255, green: 165/255, blue: 216/255, alpha: 1)
    let bodyView = UIView()
    bodyView.frame = self.view.frame
    bodyView.frame.origin.y -= 20 + 44
    self.view.addSubview(bodyView)
    
    //let tableView = SampleTableView(frame: self.view.frame, style: UITableViewStyle.Plain)
    
    let tableViewWrapper = PullToBounceWrapper(scrollView: tableView)
    bodyView.addSubview(tableViewWrapper)
    
    tableViewWrapper.scrollViewDidScroll()
    tableViewWrapper.didPullToRefresh = {
        NSTimer.schedule(repeatInterval: 2) { timer in
            tableViewWrapper.stopLoadingAnimation()
        }
    }
    
    //makeHeader()
}
 */

func makeHeader() {
    let headerView = UIView()
    headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 64)
    headerView.backgroundColor = UIColor(red:89/255, green: 165/255, blue: 216/255, alpha: 1)
    self.view.addSubview(headerView)
    
    let headerLine = UILabel()
    headerLine.frame = CGRect(x: 0, y: 0, width: 120, height: 100)
    headerLine.center = CGPoint(x: headerView.frame.center.x + 25, y: 20 + 44/2)
    headerLine.textColor = UIColor.whiteColor()
    headerLine.text = "Storm"
    headerView.addSubview(headerLine)
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    

    func refresh(){
        info_request()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return member.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellTableIdentifier, forIndexPath: indexPath) as  UITableViewCell
        //var cell = tableView.dequeueReusableCellWithIdentifier(cellTableIdentifier)! as UITableViewCell

        cell.detailTextLabel?.sizeToFit()
        cell.detailTextLabel?.hidden = false

        cell.textLabel?.text = self.member[indexPath.row].name
        //cell.imageView?.image = nil
        switch (self.member[indexPath.row].checkValue) {
            case "Y" : cell.detailTextLabel?.text = "참석"
            case "N" : cell.detailTextLabel?.text = "불참"
            case "X" : cell.detailTextLabel?.text = "미정"
            default: cell.detailTextLabel?.text = "미정"
        }

        
        return cell
    }
    
    //checkValue, profileimage, destday re-confirm
    func info_request() {
        
        let subUrl: String = "xe/work/mobile_checklist.php"
        
        //let userId: String = NSUserDefaults.standardUserDefaults().stringForKey("userId")!
        //let userSrl: String = NSUserDefaults.standardUserDefaults().stringForKey("userSrl")!
        
        let myUrl: NSURL = NSURL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(URL:myUrl)
        request.HTTPMethod = "GET"
        
        //HTTPBody request is POST
        //let postString = "work_type=R&user_id=" + userId + "&user_srl=" + userSrl
        //request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding);
        
       
        var isFail: Bool = false
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            guard data != nil else {
                print("error=\(error)");
                self.refreshControl.endRefreshing()
                return
            }
            
            do {
                
                if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String!
                    print("result: \(resultValue)")
                    
                    if(resultValue != nil && resultValue == "success"){
                        do {
                            self.member.removeAll()
                            if let jsonData = json["data"] as? [[String: AnyObject]]{
                            for data in jsonData {
                                let info = userInfo()
                                info.id = (data["userid"] as? String)!
                                info.name = (data["username"] as? String)!
                                info.department = (data["department"] as? String)!
                                info.checkValue = (data["checkvalue"] as? String)!
                                info.checkTime = (data["checkdate"] as? String)!
                                info.photoUrlPath = (data["profileimage_src"] as? String)!
                                info.deviceUrlPath = (data["deviceimage_src"] as? String)!
                                self.member.append(info)
                                    print("\(info.id) : \(info.name)")
                                }
                            }

                        
                            let destDayText = json["destdayText"] as! String!
                            let yescheckCount = json["yescheckCount"] as! String!
                            let nocheckCount = json["nocheckCount"] as! String!
                            let notcheckCount = json["notcheckCount"] as! String!

                            self.refreshControl.attributedTitle = NSAttributedString(string: "last update : \(NSDate())")
                            self.tableViewController.tableView.reloadData()
                        } catch {
                            print("error: parsing")
                            isFail = true
                        }
                        self.refreshControl.endRefreshing()
                    
                    } else {
                        let jsonStr = NSString(data:data!, encoding: NSUTF8StringEncoding)
                        print("error:\(jsonStr)")
                        isFail = true
                    }
                } else {
                    let jsonStr = NSString(data:data!, encoding: NSUTF8StringEncoding)
                    print("error:\(jsonStr)")
                    isFail = true
                }
            } catch let error as NSError {
                print(error)
                let jsonStr = NSString(data:data!, encoding: NSUTF8StringEncoding)
                print("error:\(jsonStr)")
                isFail = true
            }
            
            if(isFail){
                self.refreshControl.endRefreshing()
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                });
            }
        }
        task.resume();
    }
    
    
    
    func displayAlertMessage(userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertControllerStyle.Alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertActionStyle.Default, handler:nil);
        
        myAlert.addAction(okAction);
        self.presentViewController(myAlert, animated:true, completion:nil);
        
        
        /*
         let alert = UIAlertView()
         alert.title = ""
         alert.message = userMessage
         alert.addButtonWithTitle("확인")
         alert.show()
         */
    }
}

