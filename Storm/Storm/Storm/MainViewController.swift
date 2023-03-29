//
//  FirstViewController.swift
//  Storm
//
//  Created by Vagrant on 4/5/16.
//  Copyright © 2016 Storm. All rights reserved.
//

import UIKit
import Foundation


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

var userInfos = UserInfoManager()

class MainViewController: UIViewController {
    
    let urlString: String = "http://www.acstorm.net/"
    var loading: UIActivityIndicatorView!

    @IBOutlet weak var ScrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var checkSegment: UISegmentedControl!
    @IBOutlet weak var gameDayLabel: UILabel!
    @IBOutlet weak var StatChartView: PieChartView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var seasonDateText: UILabel!
    
    var tabBarItem1 : UITabBarItem = UITabBarItem()
    var tabBarItem2 : UITabBarItem = UITabBarItem()
    var tabBarItem3 : UITabBarItem = UITabBarItem()
    var tabBarItem4 : UITabBarItem = UITabBarItem()

    var currentYear: Int = 0
    var timeFormat = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timeFormat.locale = Locale(identifier: "ko_kr")
        self.timeFormat.timeZone = TimeZone(identifier: "KST")
        self.timeFormat.dateFormat = "yyyyMMdd"
        
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        if let arrayOfTabbarItems = tabBarControllerItems as AnyObject as? NSArray{
            tabBarItem1 = arrayOfTabbarItems[0] as! UITabBarItem
            tabBarItem2 = arrayOfTabbarItems[1] as! UITabBarItem
            tabBarItem3 = arrayOfTabbarItems[2] as! UITabBarItem
            tabBarItem4 = arrayOfTabbarItems[3] as! UITabBarItem

        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.topItem?.title = "나"
 
        //tabBarItem2.badgeValue = "1"
        //tabBarItem3.enabled = false
     
        self.profileImageView.layer.cornerRadius = 10.0
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.masksToBounds = true;
        self.profileImageView.layer.borderWidth = 2.0
        self.profileImageView.layer.borderColor = UIColor.white.cgColor
        self.profileImageView.layer.zPosition = 1
        
        seasonDateText.text = ""
        StatChartView.noDataText = "참석율 확인중.."
        StatChartView.descriptionText = ""
        StatChartView.backgroundColor = UIColor.white
        StatChartView.legend.enabled = false
        StatChartView.drawEntryLabelsEnabled = true
 
        ScrollView.contentSize.height = StatChartView.layer.frame.top + StatChartView.layer.frame.size.height + seasonDateText.frame.size.height + 10
        
        self.checkSegment.isEnabled = !UserDefaults.standard.bool(forKey: "isAdmin")
        
        self.loading = UIActivityIndicatorView(style: .whiteLarge)
        self.loading.color = UIColor.orange
        self.loading.frame = CGRect(x: Device.TheCurrentDeviceWidth / 2 - 50, y: Device.TheCurrentDeviceHeight / 2 - 50, width: 100, height: 100)
        self.loading.stopAnimating()
        view.addSubview(loading)
        
        info_request()
       
        //all user info
        userInfos.allUserInfoRequest()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "isLogged")){
            let destDay = UserDefaults.standard.string(forKey: "destDay")
            let toDay = self.timeFormat.string(from: Date())
            
            //이전 로그인시에 확인 한 다음경기일자가 오늘보다 작으면 지난주 정보이므로 정보를 새로그침
            if (destDay < toDay){
                info_request()
            }

            
            /*
            let userName = UserDefaults.standard.string(forKey:"userName")
            let destDayText = UserDefaults.standard.string(forKey: "destDayText")
            let checkValue = UserDefaults.standard.string(forKey: "checkValue")
            let profileImage = UserDefaults.standard.string(forKey: "profileImage")
            
            self.viewUserInfo(profileImage!, uName:userName!, dDayText: destDayText!, check: checkValue!)
            */
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func drawChart(_ seasonPercent: Float, xTextValues: [String], values: [Double], colors: [UIColor]) {

        StatChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOptionX: .easeOutBack, easingOptionY: .easeOutBack)
     
        var yValues: [Double] = values
        var alphaValue:CGFloat = 1.0
        var xColors: [UIColor] = []
        
        //시즌참석율이 0 이라는건 시즌첫주에 아무런 결과가 없을때, 5개종류를 똑같이 표시되게 값을 20으로 넣고, 칼라도 반투명으로
        if (seasonPercent == 0.0) {
            alphaValue = 0.5
            yValues = [20.0, 20.0, 20.0, 20.0, 20.0]
            
            let color1 = UIColor(red: 103/255, green: 163/255, blue: 247/255, alpha: alphaValue)
            xColors.append(color1)
            
            let color2 = UIColor(red: 106/255, green: 252/255 , blue: 113/255, alpha: alphaValue)
            xColors.append(color2)
            
            let color3 = UIColor(red: 252/255, green: 115/255 , blue: 106/255, alpha: alphaValue)
            xColors.append(color3)
            
            let color4 = UIColor(red: 255/255, green: 204/255 , blue: 102/255, alpha: alphaValue)
            xColors.append(color4)
            
            let color5 = UIColor(red: 152/255, green: 152/255 , blue: 152/255, alpha: alphaValue)
            xColors.append(color5)
        } else {
            xColors = colors
        }
        
        // PieCharet
        var dataEntries: [PieChartDataEntry] = []
        for i in 0 ..< xTextValues.count {
            if (yValues[i] > 0){
                let dataEntry = PieChartDataEntry(value: yValues[i], label: xTextValues[i])
                dataEntries.append(dataEntry)
            }
        }
 
        let chartDataSet = PieChartDataSet(values: dataEntries, label: "stat")
        
        chartDataSet.sliceSpace = 2.0;
        chartDataSet.valueLinePart1OffsetPercentage = 0.8;
        chartDataSet.valueLinePart1Length = 0.5;
        chartDataSet.valueLinePart2Length = 0.5;
        chartDataSet.xValuePosition = .outsideSlice;
        chartDataSet.yValuePosition = .outsideSlice;
        chartDataSet.valueTextColor = UIColor.black
        chartDataSet.drawValuesEnabled = seasonPercent > 0.0
        
        let chartData = PieChartData(dataSet: chartDataSet)
        chartData.setDrawValues(true)
        
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent;
        pFormatter.maximumFractionDigits = 2;
        pFormatter.multiplier = 1.0
        pFormatter.percentSymbol = "%";
        
        let pFormat = DefaultValueFormatter()
        pFormat.formatter = pFormatter

        chartData.setValueFormatter(pFormat)
        
        StatChartView.drawCenterTextEnabled = true
        StatChartView.centerText = String(format: "시즌\n참석률\n(%.02f", seasonPercent) + "%)"
        StatChartView.data = chartData
        
        chartDataSet.colors = xColors

     }
 
  
    @IBAction func checkChangeTapped(_ sender: UISegmentedControl) {
        
        let logined = UserDefaults.standard.bool(forKey: "isLogged")
        if(logined == false){
            displayAlertMessage("로그인후 사용하세요!!")
            return;
        }
        
        if (sender.numberOfSegments == 2){
            switch sender.selectedSegmentIndex {
                case 0 : check_request("Y")
                case 1 : check_request("N")
                default: break;
            }
        } else if (sender.numberOfSegments == 3){
            switch sender.selectedSegmentIndex {
                case 0 : check_request("Y")
                case 1 : displayAlertMessage("참석 or 불참") //check_request(check: "N")
                case 2 : check_request("N")
                default: break;
            }
        }
        
    }

    @IBAction func refreshButtonTapped(_ sender: AnyObject) {
        info_request()
        userInfos.allUserInfoRequest()
    }
    
    @IBAction func logoutButtonTapped(_ sender: AnyObject) {
        
        let confirm = UIAlertController(title: "스톰", message:"로그아웃 하시겠습니까?", preferredStyle: UIAlertController.Style.alert )
        
        confirm.addAction(UIAlertAction(title: "예", style: UIAlertAction.Style.default, handler: { action in
            UserDefaults.standard.set(false, forKey: "isLogged")
            
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
            self.present(loginViewController, animated: true, completion: nil)
        }))
        confirm.addAction(UIAlertAction(title: "아니오", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(confirm, animated:true, completion:nil);
    }
    
   
    func viewUserInfo(_ imageUrl: String,
                      uName userName: String,
                      dDayText destDayText: String,
                      check checkValue: String){

        
        //갱신은 메인쓰레드에서 한다.
        DispatchQueue.main.async(execute: {
            
            self.userNameLabel.text = userName
            self.gameDayLabel.text = destDayText
            self.checkSegment.isEnabled = !UserDefaults.standard.bool(forKey: "isAdmin")
        
            self.checkSegment.removeAllSegments()
            if(checkValue != "X"){
                self.checkSegment.insertSegment(withTitle: "참석", at: 1, animated: true)
                self.checkSegment.insertSegment(withTitle: "불참", at: 2, animated: true)
            } else {
                self.checkSegment.insertSegment(withTitle: "참석", at: 0, animated: true)
                self.checkSegment.insertSegment(withTitle: "미정", at: 1, animated: true)
                self.checkSegment.insertSegment(withTitle: "불참", at: 2, animated: true)
            }
    
            switch checkValue {
                case "Y" :
                    self.checkSegment.selectedSegmentIndex = 0
                case "N" :
                    self.checkSegment.selectedSegmentIndex = 1
                case "X" :
                    self.checkSegment.selectedSegmentIndex = 1
                default: break;
            }

            //user profile image
            let imageDefault = UIImage(named: "Contacts-50.png")!
            let imageURL = URL(string: imageUrl)
            if (!imageUrl.isEmpty && imageURL != nil) {
                if let image = imageURL!.cachedImage {
                    print("cached image")
                    self.profileImageView.image = image
                    self.profileImageView.alpha = 1
                } else {
                    self.profileImageView.alpha = 0
                    imageURL!.downImage{ image in
                        self.profileImageView.image = image
                        UIView.animate(withDuration: 0.5, animations: {
                            self.profileImageView.alpha = 1
                        }) 
                        print("download image")
                    }
                }
            } else {
                self.profileImageView.image = imageDefault
            }
            
            self.stat_request()
        })
    }


    func check_request(_ check: String){

        self.loading.startAnimating()
        
        var isFail: Bool = false
        
        let userId: String = UserDefaults.standard.string(forKey: "userId")!
        //let userName: String = NSUserDefaults.standardUserDefaults().stringForKey("userName")!
        let checkValue: String = UserDefaults.standard.string(forKey: "checkValue")!
        let destDay: String = UserDefaults.standard.string(forKey: "destDay")!
        
        //HTTPBody request is POST
        var workType: String = "C"
        if checkValue != "X" {
            workType = "U"
        }
        var checkValueText = "불참"
        if (check == "Y"){
            checkValueText = "참석"
        }
        let subUrl : String = "xe/work/mobile_check.php"
        let postString = "work_type=" + workType + "&user_id=" + userId + "&destday=" + destDay + "&check=" + check + "&mobile=2"
        let myUrl: URL = URL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                self.loading.stopAnimating()
                self.displayAlertMessage("정보 변경 실패, 잠시후 재시도 하세요.")
                print("error=\(error)");
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String?
                    
                    var resultText: String
                    if(resultValue != nil && resultValue == "success"){
                        
                        //let uname = json["uname"] as! String!
                        //print("name: \(uname)")
                        UserDefaults.standard.set(check, forKey: "checkValue")
                        UserDefaults.standard.synchronize()
                        
                        resultText = "[\(checkValueText)]으로 변경 완료했습니다."
                    } else {
                        resultText = "[\(checkValueText)]으로 변경에 실패했습니다."

                    }
                    DispatchQueue.main.async(execute: {
                        self.displayAlertMessage(resultText)
                    });

                    
                } else {
                    isFail = true
                    let jsonStr = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)
                    print("error:\(jsonStr)")
                }
            } catch let error as NSError {
                print(error)
                isFail = true
                let jsonStr = NSString(data:data!, encoding: String.Encoding.utf8.rawValue)
                print("error:\(jsonStr)")
            }
            
            DispatchQueue.main.async(execute: {
                if(isFail){
                    self.displayAlertMessage("정보 변경 실패, 잠시후 재시도 하세요.")
                } else {
                    self.checkSegment.removeAllSegments()
                    self.checkSegment.insertSegment(withTitle: "참석", at: 1, animated: true)
                    self.checkSegment.insertSegment(withTitle: "불참", at: 2, animated: true)

                
                    switch check {
                    case "Y" :
                        self.checkSegment.selectedSegmentIndex = 0
                    case "N" :
                        self.checkSegment.selectedSegmentIndex = 1
                    default: break;
                    }
                }
                self.loading.stopAnimating()
            })
        };
        task.resume();
    }
        
    
    //checkValue, profileimage, destday re-confirm
    func info_request() {
    
        self.loading.startAnimating()
        self.checkSegment.isEnabled = false
        
        let userId: String = UserDefaults.standard.string(forKey: "userId")!
        let userSrl: String = UserDefaults.standard.string(forKey: "userSrl")!
        
        let subUrl : String = "xe/work/mobile_check.php"
        let myUrl: URL = URL(string: urlString + subUrl)!

        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        
        //HTTPBody request is POST
        let postString = "work_type=R&user_id=" + userId + "&user_srl=" + userSrl
        request.httpBody = postString.data(using: String.Encoding.utf8);
        //print("request.HTTPBody=\(request.HTTPBody!)");
        
        var isFail: Bool = false

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                self.loading.stopAnimating()
                self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                print("error=\(error)");
                return
            }

            do {

                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String?
                    //print("result: \(resultValue)")
                    
                    if(resultValue != nil && resultValue == "success"){
                        let profileImage = json["profileimage"] as? String?
                        let destDayText = json["destdaytext"] as! String?
                        let destDay = json["destday"] as! String?
                        let checkValue = json["check"] as! String?
                        
                        UserDefaults.standard.set(profileImage, forKey: "profileImage")
                        UserDefaults.standard.set(checkValue, forKey: "checkValue")
                        UserDefaults.standard.set(destDayText, forKey: "destDayText")
                        UserDefaults.standard.set(destDay, forKey: "destDay")
                        UserDefaults.standard.synchronize()
                        
                        let userName: String = UserDefaults.standard.string(forKey: "userName")!
                        self.viewUserInfo(profileImage! ?? <#default value#>, uName:userName, dDayText: destDayText!, check: checkValue!)

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
                if(isFail){
                    self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                }
                self.loading.stopAnimating()
            })
            
        };
        task.resume();
    }
    
    
    //참석통계현황
    func stat_request() {
        
        self.loading.startAnimating()

        let userId: String = UserDefaults.standard.string(forKey: "userId")!
        
        let subUrl : String = "xe/work/mobile_check.php"
        let myUrl: URL = URL(string: urlString + subUrl)!

        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        
        //HTTPBody request is POST
        let postString = "work_type=S&&user_id=" + userId
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        var isFail: Bool = false
        var seasondaytext: String = "0000-00-00 ~ 0000-00-00"
        var seasonpercent: Float = 0.0
        var valuesPercent = [Double]()
        var chartXTitles: [String] = []
        var chartColors: [UIColor] = []
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                self.loading.stopAnimating()
                self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                print("error=\(error)");
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String?
                    //print("result: \(resultValue)")
                    
                    if(resultValue != nil && resultValue == "success"){
                        let fullplaycount = json["fullplaycount"] as! Int?
                        let playcount = json["playcount"] as! Int?
                        let noplaycount = json["noplaycount"] as! Int?
                        let falsecount = json["falsecount"] as! Int?
                        let nocheckcount = json["nocheckcount"] as! Int?
                        let totalgamecount = json["totalgamecount"] as! Int?
                        seasonpercent = (json["percent"] as! Float?)!
                        seasondaytext = json["seasondaytext"] as! String? ?? <#default value#>
                        
                        let totalCount = Double(totalgamecount!)

                        //5가지종류가 모두있지 않는경우에 챠트의 x축의 값과 칼라가 일치하지 않아서 여기서 각 값을 확인 및 배열에 넣어서 넘겨준다.
                        if (fullplaycount! > 0){
                            chartXTitles.append("풀참(\(fullplaycount!))")
                            valuesPercent.append((Double(fullplaycount!)/totalCount) * 100)
                            chartColors.append(UIColor(red: 103/255, green: 163/255, blue: 247/255, alpha: 1))
                        }
                        
                        if (playcount! > 0){
                            chartXTitles.append("참석(\(playcount!))")
                            valuesPercent.append((Double(playcount!)/totalCount) * 100)
                            chartColors.append(UIColor(red: 106/255, green: 252/255 , blue: 113/255, alpha: 1))
                        }
                        
                        if (noplaycount! > 0){
                            chartXTitles.append("불참(\(noplaycount!))")
                            valuesPercent.append((Double(noplaycount!)/totalCount) * 100)
                            chartColors.append(UIColor(red: 252/255, green: 115/255 , blue: 106/255, alpha: 1))
                        }
                        
                        if (falsecount! > 0){
                            chartXTitles.append("구라(\(falsecount!))")
                            valuesPercent.append((Double(falsecount!)/totalCount) * 100)
                            chartColors.append(UIColor(red: 255/255, green: 204/255 , blue: 102/255, alpha: 1))
                        }
                        
                        if (nocheckcount! > 0){
                            chartXTitles.append("쌩까(\(nocheckcount!))")
                            valuesPercent.append((Double(nocheckcount!)/totalCount) * 100)
                            chartColors.append(UIColor(red: 152/255, green: 152/255 , blue: 152/255, alpha: 1))
                        }
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
                self.drawChart(seasonpercent, xTextValues: chartXTitles, values: valuesPercent, colors: chartColors)
                self.seasonDateText.text = seasondaytext
                if(isFail){
                    self.StatChartView.noDataText = "결과 없음"
                    self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                }
            })
            
        };
        task.resume();
    }
    
    
    func displayAlertMessage(_ userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertAction.Style.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);

    }
    
}

