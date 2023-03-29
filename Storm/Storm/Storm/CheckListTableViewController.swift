//
//  CheckListTableViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 22..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit
import MessageUI


let imageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    func loadImageUsingCacheWithUrl(urlString: String) {
        self.image = nil
        
        // check for cache
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // download image from url
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            if error == nil {
                self.image = UIImage(data: data!)!
            } else {
                return
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                imageCache.setObject(self.image!, forKey: urlString as AnyObject)
                //self.image = self.image
            })
        }).resume()
    }
}


class CheckListTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate {

    enum memberStat :Int {
        case all = 0
        case nocheck = 1
        case uncheck = 2
    }
    
    let cellTableIdentifier = "CheckListCell"
    var timeFormat = DateFormatter()
    let urlString: String = "http://www.acstorm.net/"
    var members = [userInfo]()
    var loading = UIActivityIndicatorView()
    var selectedMemberIndex: Int = 0
    var headerTitle: String?
    @IBOutlet weak var allSendMessage: UIBarButtonItem!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.sectionHeaderHeight = 50
        
        self.members.removeAll()
        
        self.navigationController?.navigationBar.topItem?.title = "체크현황"
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.refreshControl?.addTarget(self, action: #selector(self.infoRequest), for: UIControl.Event.valueChanged)
        self.refreshControl?.tintColor = UIColor.orange
        
        //let nib = UINib(nibName: "CheckListTableViewCell", bundle: nil)
        //tableView.registerNib(nib, forCellReuseIdentifier: cellTableIdentifier)
        //tableView.allowsSelection = true
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.timeFormat.locale = Locale(identifier: "ko_kr")
        self.timeFormat.timeZone = TimeZone(identifier: "KST")
        self.timeFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.loading = UIActivityIndicatorView(style: .whiteLarge)
        self.loading.color = UIColor.orange
        self.loading.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 150, width: 100, height: 100)
        self.loading.hidesWhenStopped = true
        self.loading.startAnimating()
        self.view.addSubview(loading)
        
        infoRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as? CheckListTableViewCell
        
        let data = members[(indexPath as NSIndexPath).row]
        
        cell!.nameLabel.text = data.name
        cell!.profileImage.image = data.profileImage
        cell!.inPlayRatioLabel.text = String(format: "시즌 참석률 (%.02f", data.playRatio) + "%)"
        cell!.inPlayRatio.progress = data.playRatio / 100

        let checkTime = data.checkTime
        cell!.checkTimeLabel.text = checkTime
        if (data.changed) {
            cell!.checkTimeLabel.textColor = UIColor.orange
        } else {
            cell!.checkTimeLabel.textColor = UIColor.lightGray
        }
        
        switch (data.checkValue) {
            case "Y" : cell!.checkLabel.text =  "참석"
                cell!.checkLabel.textColor = UIColor.blue
            
            case "N" : cell!.checkLabel.text = "불참"
                cell!.checkLabel.textColor = UIColor.red
            
            case "X" : cell!.checkLabel.text = "미정"
                cell!.checkLabel.textColor = UIColor.gray
            
            default: cell!.checkLabel.text = "미정"
                cell!.checkLabel.textColor = UIColor.gray
            
        }
        
        
        //url exist
        if (data.photoURL != nil) {
            if let image = data.photoURL.cachedImage {
                print("cached image")
                cell!.profileImage.image = image
                cell!.profileImage.alpha = 1
            } else {
                cell!.profileImage.alpha = 1
                data.photoURL.downImage{ image in
                    cell!.profileImage.image = image
                    UIView.animate(withDuration: 0.5, animations: {
                        cell!.profileImage.alpha = 1
                    })
                    print("download image")
                }
            }
        } else {
            cell!.profileImage.alpha = 1
        }
 
        
        /*
        let proimage = UIImageView()
        proimage.loadImageUsingCacheWithUrl(urlString: data.photoUrlPath)
        if proimage.image != nil {
            cell!.profileImage.image = proimage.image
            cell!.profileImage.alpha = 1
        }
        */

        /*
        let accesoryBadge = UILabel()
        let text = "2"

        accesoryBadge.text = text
        accesoryBadge.textColor = UIColor.whiteColor()
        accesoryBadge.font = UIFont(name: "Lato-Regular", size: 16.0)
        accesoryBadge.textAlignment = NSTextAlignment.Center
        accesoryBadge.layer.cornerRadius = 4
        accesoryBadge.clipsToBounds = true
        accesoryBadge.backgroundColor = UIColor.orangeColor()
        accesoryBadge.frame = CGRectMake(0, 0, 20, 20)
        cell?.accessoryView = accesoryBadge
        */
        
        return cell!
    }
    
    //선택 row 기억하고 상세보기 세그로 화면 전환
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRow(at: indexPath) {
            selectedMemberIndex = (indexPath as NSIndexPath).row
            //print("row \(indexPath.row) selected")
            self.performSegue(withIdentifier: "memberDetailSegue", sender: self)
        }

    }
    
    //상세보기 화면전환 될때 회원정보 넘겨주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "memberDetailSegue"){
            let destinationView = segue.destination as! MemberInfoDetailViewController
            destinationView.member = members[selectedMemberIndex]
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let vw = UIView()
            vw.backgroundColor = UIColor.white
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.text = headerTitle
            
            vw.addSubview(titleLabel)

            return vw
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    

    func getAllTelnumbers(_ stat : memberStat) -> [String] {
        var tels = [String]()
        if (self.members.count > 0) {
            for i in 0 ... members.count-1 {
                switch stat {
                case .all:
                    let telnumber = self.members[i].telno.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                    tels.append(telnumber)
                case .nocheck:
                    if (self.members[i].checkValue == "N"){
                        let telnumber = self.members[i].telno.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                        tels.append(telnumber)
                    }
                case .uncheck:
                    if (self.members[i].checkValue == "X"){
                        let telnumber = self.members[i].telno.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
                        tels.append(telnumber)
                    }
                default:
                    break
                }

            }
        }
        return tels
    }
    
    func getMember(id: String) -> userInfo? {
        if (self.members.count > 0) {
            for i in 0 ... members.count-1 {
                if (self.members[i].id == id) {
                    return self.members[i]
                }
            }
        }
        return nil
    }
    
    func existMember(_ id: String) -> Int {
        if (self.members.count > 0) {
            for i in 0 ... members.count-1 {
                if (self.members[i].id == id) {
                    return i
                }
            }
        }
        return -1
    }
    
    @IBAction func smsSendButton(_ sender: AnyObject) {
        
        let confirm = UIAlertController(title: "스톰", message: "단체 메세지 보내기", preferredStyle: UIAlertController.Style.actionSheet )
        
        confirm.addAction(UIAlertAction(title: "전체 보내기", style: UIAlertAction.Style.default, handler: { action in
            if (MFMessageComposeViewController.canSendText()) {
                let smsController = MFMessageComposeViewController()
                smsController.body = "[스톰]"
                smsController.recipients = self.getAllTelnumbers(.all)
                smsController.messageComposeDelegate = self
                self.present(smsController, animated: true, completion: nil)
                
            } else {
                self.displayAlertMessage("메세지를 보낼 수 없습니다.")
                print("no permision")
            }
        }))
        
        confirm.addAction(UIAlertAction(title: "미정자 보내기", style: UIAlertAction.Style.default, handler: { action in
            if (MFMessageComposeViewController.canSendText()) {
                let smsController = MFMessageComposeViewController()
                smsController.body = "[스톰]"
                smsController.recipients = self.getAllTelnumbers(.uncheck)
                smsController.messageComposeDelegate = self
                self.present(smsController, animated: true, completion: nil)
                
            } else {
                self.displayAlertMessage("메세지를 보낼 수 없습니다.")
                print("no permision")
            }
        }))
        
        confirm.addAction(UIAlertAction(title: "불참체크자 보내기", style: UIAlertAction.Style.default, handler: { action in
            if (MFMessageComposeViewController.canSendText()) {
                let smsController = MFMessageComposeViewController()
                smsController.body = "[스톰]"
                smsController.recipients = self.getAllTelnumbers(.nocheck)
                smsController.messageComposeDelegate = self
                self.present(smsController, animated: true, completion: nil)
                
            } else {
                self.displayAlertMessage("메세지를 보낼 수 없습니다.")
                print("no permision")
            }
        }))
        
        confirm.addAction(UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(confirm, animated:true, completion:nil);
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message Called, \(String(describing: controller.recipients))")
        case MessageComposeResult.failed.rawValue:
            print("Message Failed, \(String(describing: controller.recipients))")
        case MessageComposeResult.sent.rawValue:
            print("Message was sent, \(String(describing: controller.recipients))")
            
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    //checkValue, profileimage, destday re-confirm
    @objc func infoRequest() {
        self.allSendMessage.isEnabled = false
        
        let subUrl: String = "xe/work/mobile_checklist.php"
        
        let myUrl: URL = URL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "GET"
        
        var isFail: Bool = false
        var destDayText: String = ""
        var yescheckCount: Int = 0
        var nocheckCount: Int = 0
        var notcheckCount: Int = 0
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                print("error=\(String(describing: error))");
                self.refreshControl?.endRefreshing()
                self.loading.stopAnimating()
                
                //self.view.willRemoveSubview(self.loading)
                self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String?
                    print("result: \(String(describing: resultValue))")
                    
                    if(resultValue != nil && resultValue == "success"){
                        do {
                            if let jsonData = json["data"] as? [[String: AnyObject]]{
                                var index: Int = 0
                                for data in jsonData {
                                    let info = userInfo()
                                    info.id = (data["userid"] as? String)!
                                    info.name = (data["username"] as? String)!
                                    info.telno = (data["telno"] as? String)!
                                    info.department = (data["department"] as? String)!
                                    info.checkValue = (data["checkvalue"] as? String)!
                                    info.checkTime = (data["checkdate"] as? String)!
                                    info.photoUrlPath = (data["profileimage_src"] as? String)!
                                    info.deviceUrlPath = (data["deviceimage_src"] as? String)!
                                    info.playRatio = (data["ratio"] as? Float)!
                                    
                                    if (!info.photoUrlPath.isEmpty && info.photoUrlPath != "-") {
                                        info.photoURL = URL(string: info.photoUrlPath)
                                        //info.photoURL = ImageURL
                                    } else {
                                        info.photoURL = nil
                                    }
                                    

                                    //목록에 정보가 있으면 갱신, 없으면 추가
                                    let memberIndex = self.existMember(info.id)
                                    if memberIndex >= 0 {
                                        //print("member update : \(info.id) : \(info.name) : \(info.photoUrlPath)")
                                        if (self.members[memberIndex].checkTime != info.checkTime){
                                            info.changed = true
                                        }
                                        self.members[memberIndex] = info
                                    } else {
                                        self.members.insert(info, at: index)
                                        //self.members.append(info)
                                    }
                                    index = index + 1
                                }
                            }
                            
                            destDayText = (json["destdaytext"] as! String?)!
                            yescheckCount = (json["yescheckcount"] as! Int?)!
                            nocheckCount = json["nocheckcount"] as! Int? ?? <#default value#>
                            notcheckCount = (json["notcheckcount"] as! Int?)!
                            
                        } catch {
                            print("error: parsing")
                            isFail = true
                        }
                        self.refreshControl?.endRefreshing()
                        
                    } else {
                        let jsonStr = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)
                        print("error:\(jsonStr)")
                        isFail = true
                    }
                } else {
                    let jsonStr = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)
                    print("error:\(jsonStr)")
                    isFail = true
                }
            } catch let error as NSError {
                print(error)
                let jsonStr = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)
                print("error:\(jsonStr)")
                isFail = true
            }
            
            DispatchQueue.main.async(execute: {
                self.loading.stopAnimating()
                //self.view.willRemoveSubview(self.loading)
                
                if(isFail){
                    self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                } else {
                    self.allSendMessage.isEnabled = true
                    self.headerTitle = "\(destDayText) [참석:\(yescheckCount) 불참:\(nocheckCount) 미정:\(notcheckCount)]"
                    let nowTime = self.timeFormat.string(from: Date())
                    self.refreshControl?.attributedTitle = NSAttributedString(string: "마지막 확인 시간 : \(nowTime)")
                    self.tableView.reloadData()
                }
                self.refreshControl?.endRefreshing()
            })
        };
        task.resume();
    }
    
    
    func displayAlertMessage(_ userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertAction.Style.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
        
        
        /*
         let alert = UIAlertView()
         alert.title = ""
         alert.message = userMessage
         alert.addButtonWithTitle("확인")
         alert.show()
         */
    }
    
    
    
    
}
