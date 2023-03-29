//
//  PersonalRecordSearchViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 7. 11..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class RecordStat {
    var check:Int = 0
    var fullCheck:Int = 0
    var noCheck:Int = 0
    var falseCheck:Int = 0
    var notCheck:Int = 0
    var gole:Int = 0
    var assist:Int = 0
    var mvp:Int = 0
}

class PersonalRecordSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var topView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    enum workType :Int {
        case read = 0
        case add = 1
        case edit = 2
        case delete = 3
    }
    
    let cellTableIdentifier = "PersonalRecordListCell2"
    
    var dateFormatter = DateFormatter()
    let urlString: String = "http://www.acstorm.net/"
    var personalInfos = [personalRecordInfo]()
    var loading = UIActivityIndicatorView()
    var selectIndex = -1
    var headerTitle: String?
    var personalInfo: personalRecordInfo!
    let processStat = workType.read
    var deleteIndex: IndexPath!
    var gameDay: String?
    var recordStat: RecordStat!

    var startDay: String = ""
    var endDay: String = ""
    var startDate: Date?
    var endDate: Date?
    var startDateEditing: Bool?
    var datePicker : UIDatePicker!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.topView.frame.height = 90
        self.tableView.rowHeight = 50
        
        //self.tableView.sectionHeaderHeight = 50
        //self.tableView.sectionFooterHeight = 50
        
        self.personalInfos.removeAll()
        
        self.userName.setTitle(personalInfo.name, for: UIControlState())
        self.navigationItem.title = "개인기록"

        self.startDateField.delegate = self
        self.endDateField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.loading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.loading.color = UIColor.orange
        self.loading.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 150, width: 100, height: 100)
        self.loading.hidesWhenStopped = true
        self.loading.startAnimating()
        self.tableView.addSubview(loading)
        
        self.selectIndex = -1
        self.startDay = ""
        self.endDay = ""
        refreshContorolPull()
        
        //print("viewDidLoad")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("viewDidAppear")

    }
    
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //add 화면에서 cancel 버튼으로 돌아왔을때
    @IBAction func cancelAddView(_ segue: UIStoryboardSegue){
        print("cancelTeamAddView")
        selectIndex = -1
        
    }
    
    
    //add 화면에서 done 버튼으로 돌아왔을때
    @IBAction func doneAddView(_ segue: UIStoryboardSegue){
        if let destinationView = segue.source as? PersonalRecordAddViewController {
            print("PersonalRecordAddViewController")
            self.personalInfo = destinationView.personalInfo
            print("date : \(self.personalInfo.date)")
            print("gameday : \(self.personalInfo.gameday)")
            print("gole : \(self.personalInfo.gole)")
            print("assist : \(self.personalInfo.assist)")
            print("mvp : \(self.personalInfo.mvp)")
            print("result : \(self.personalInfo.result)")
            //infoRequest(.ADD)
 
        }
        selectIndex = -1
        
    }
    
    func tapped() {
        //print("tapped")
        self.view.endEditing(true)
    }

    
    @IBAction func startDateEdit(_ sender: UITextField) {
        self.startDateEditing = true
        datePicker(sender)
    }

    @IBAction func endDateEdit(_ sender: UITextField) {
        self.startDateEditing = false
        datePicker(sender)
    }
    
    func datePicker(_ sender: UITextField) {
       
        self.datePicker = UIDatePicker()
        self.datePicker.datePickerMode = UIDatePickerMode.date
        self.datePicker.backgroundColor = UIColor.white
        
        //toolbar 
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.orange  // UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        //add button toolbar
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil,  action: nil)
        let todayButton = UIBarButtonItem(title: "오늘", style: .plain, target: self,  action: #selector(todayButtonTapped))
        let queryButton = UIBarButtonItem(title: "조회하기", style: .plain, target: self,  action: #selector(queryButtonTapped))
        toolBar.setItems([todayButton, spaceButton, queryButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        sender.inputAccessoryView = toolBar
        
        
        if(self.startDateEditing == true){
            datePicker.date = self.startDate!
        } else {
            datePicker.date = self.endDate!
        }
        
        sender.inputView = self.datePicker
        self.datePicker.addTarget(self, action: #selector(datePickerSelected), for: UIControlEvents.valueChanged)
        
    }
    
    func todayButtonTapped() {
        self.datePicker.date = Date()
        datePickerSelected(self.datePicker)
    }
    
    func queryButtonTapped() {
        refreshContorolPull()
        self.view.endEditing(true)
    }
    
    
    func datePickerSelected(_ datePic: UIDatePicker) {

        if(self.startDateEditing == true){
            dateFormatter.dateFormat = "yyyy년MM월dd일"
            self.startDateField.text = dateFormatter.string(from: datePic.date)
            dateFormatter.dateFormat = "yyyyMMdd"
            self.startDay = dateFormatter.string(from: datePic.date)
            self.startDate = datePic.date
            
            //시작날짜가 마지막날짜보다 크면 마지막일자를 +30일을 한다.
            if (self.startDay > self.endDay) {
                let endDate = dateSubtract(datePic.date, sub:30)
                
                dateFormatter.dateFormat = "yyyy년MM월dd일"
                self.endDateField.text = dateFormatter.string(from: endDate)
                dateFormatter.dateFormat = "yyyyMMdd"
                self.endDay = dateFormatter.string(from: endDate)
                self.endDate = endDate
            }

        } else {
            dateFormatter.dateFormat = "yyyy년MM월dd일"
            self.endDateField.text = dateFormatter.string(from: datePic.date)
            dateFormatter.dateFormat = "yyyyMMdd"
            self.endDay = dateFormatter.string(from: datePic.date)
            self.endDate = datePic.date
            
            //마지막날짜가 시작날짜보다 작으면 시작일자를 -30일을 한다.
            if (self.endDay < self.startDay) {
                let startDate = dateSubtract(datePic.date, sub:-30)
                
                dateFormatter.dateFormat = "yyyy년MM월dd일"
                self.startDateField.text = dateFormatter.string(from: startDate)
                dateFormatter.dateFormat = "yyyyMMdd"
                self.startDay = dateFormatter.string(from: startDate)
                self.startDate = startDate
            }
        }
    }
    
    func dateSubtract(_ jobDate: Date, sub: Int) -> Date {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        var offset = DateComponents()
        offset.day = sub
        
        return (cal as NSCalendar).date(byAdding: offset, to: jobDate, options: [])!
    }
    
    func refreshContorolPull() {
      
        let dateFormatter = DateFormatter()
        
        if (self.startDay == ""){
            //시작일이 없으면 30일 이전 날짜부터
            let startDate = dateSubtract(Date(), sub: -30)

            dateFormatter.dateFormat = "yyyy년MM월dd일"
            self.startDateField.text = dateFormatter.string(from: startDate)
            dateFormatter.dateFormat = "yyyyMMdd"
            self.startDay = dateFormatter.string(from: startDate)
            self.startDate = startDate
        }
        if (self.endDay == ""){
            let toDate = Date()
            dateFormatter.dateFormat = "yyyy년MM월dd일"
            self.endDateField.text = dateFormatter.string(from: toDate)
            dateFormatter.dateFormat = "yyyyMMdd"
            self.endDay = dateFormatter.string(from: toDate)
            self.endDate = toDate
        }

        
        infoRequest(.read)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //선택되었을때 선택row 정보확인후 화면 전환 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRow(at: indexPath) {
            selectIndex = (indexPath as NSIndexPath).row
            self.performSegue(withIdentifier: "personalRecordAddSegue", sender: self)
        }
        
    }
    
    //row select 해서 화면 전환시 값 넘겨주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("prepareForSegue")
        if (segue.identifier == "personalRecordAddSegue"){
            let DestViewController = segue.destination as! UINavigationController
            let destinationView = DestViewController.topViewController as! PersonalRecordAddViewController
            
            if (self.selectIndex >= 0) {
              personalInfo = personalInfos[selectIndex]
              destinationView.adding = false
            }
            
            destinationView.personalInfo = personalInfo
            
        }
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.personalInfos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as? PersonalRecordTableViewCell
        
        let data = personalInfos[(indexPath as NSIndexPath).row]
        
        cell!.name.text = data.gameday
        cell!.gole.text = data.gole
        cell!.assist.text = data.assist
        cell!.mvp.text = data.mvp
        
        cell!.gole.textColor = UIColor.orange
        cell!.assist.textColor = UIColor.orange
        cell!.mvp.textColor = UIColor.orange
        
        if(data.gole == "0"){
            cell!.gole.textColor = UIColor.black
            cell!.gole.text = "-"
        }
        if(data.assist == "0"){
            cell!.assist.textColor = UIColor.black
            cell!.assist.text = "-"
        }
        if(data.mvp == "0"){
            cell!.mvp.textColor = UIColor.black
            cell!.mvp.text = "-"
        }
        
        switch (data.result) {
        case "Y2" : cell?.result.text =  "참석(풀참)"
        cell?.result.textColor = UIColor.orange
            
        case "Y" : cell?.result.text = "참석"
        cell?.result.textColor = UIColor.blue
            
        case "N" : cell?.result.text = "불참"
        cell?.result.textColor = UIColor.red
            
        case "X" : cell?.result.text = "불참(구라)"
        cell?.result.textColor = UIColor.red
            
        case "X2" : cell?.result.text = "불참(쌩까)"
        cell?.result.textColor = UIColor.red
            
        default: cell?.result.text = "결과 없음"
        cell?.result.textColor = UIColor.gray
            
        }
        
        return cell!
    }
    
    
    /*
    //선택되었을때 선택row 정보확인후 화면 전환 처리
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = tableView.indexPathForSelectedRow!
        if row = tableView.cellForRowAtIndexPath(indexPath) {
            selectIndex = indexPath.row
            self.performSegueWithIdentifier("personalSearchSegue", sender: self)
        }
    }
    */
    
    /*
    //row select 해서 화면 전환시 값 넘겨주기
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("prepareForSegue")
        if (segue.identifier == "personalSearchSegue"){  //personalRecordDetailSegue
            let destinationView = segue.destinationViewController as! PersonalRecordDetailViewController
            //destinationView.personalInfo = personalInfos[selectIndex]
            let member = userInfo()
            member.name = personalInfos[selectIndex].name
            member.id = personalInfos[selectIndex].id
            member.telno = personalInfos[selectIndex].telno
            
            //destinationView.member = member// personalInfos[selectIndex]
        }
    }
    */
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        if (section == 0) {
            let vw = UIView() //frame: CGRect(x:0, y:0, width:self.tableView.frame.size.width, height: 50))
            vw.backgroundColor = UIColor.white
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.font = UIFont(name: (titleLabel.font?.fontName)!, size: 12)
            titleLabel.text = headerTitle
            
            vw.addSubview(titleLabel)
            
            return vw
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            selectIndex = (indexPath as NSIndexPath).row
            personalInfo = personalInfos[(indexPath as NSIndexPath).row]
            deleteIndex = indexPath
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            infoRequest(.delete)
        } else if editingStyle == .insert {
            
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func existData(_ gameday: String) -> Int {
        if (self.personalInfos.count > 0) {
            for i in 0 ... personalInfos.count-1 {
                if (self.personalInfos[i].gameday == gameday) {
                    return i
                }
            }
        }
        return -1
    }
    
    //checkValue, profileimage, destday re-confirm
    func infoRequest(_ type: workType) {
        
        let subUrl: String = "xe/work/mobile_personal.php"
        var postString: String = ""
        
        let myUrl: URL = URL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        
        switch type {
        case .read  : postString = "worktype=R&destday=\(self.startDay)&destdayend=\(self.endDay)&user_name=\(personalInfo.name)"
            
        case .add   : postString = "worktype=C&user_name=\(personalInfo.name)&destday=\(personalInfo.date)&gole=\(personalInfo.gole)&assist=\(personalInfo.assist)&result=\(personalInfo.result)"
            
        case .edit  : postString = "worktype=E&user_name=\(personalInfo.name)&destday=\(personalInfo.date)&gole=\(personalInfo.gole)&assist=\(personalInfo.assist)&result=\(personalInfo.result)"
            
        case .delete: postString = "worktype=D&destday=\(personalInfo.date)"
            
        }
        //print("sql : \(postString)")
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        var isFail: Bool = false
        self.loading.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                print("error=\(error)");
                self.loading.stopAnimating()
                
                self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String!
                    print("result: \(resultValue)")
                    
                    if(resultValue != nil && resultValue == "success"){
                        do {
                            switch type {
                            case .read :
                                
                                let stat = RecordStat()
                                self.recordStat = stat
                                self.personalInfos.removeAll()
                                
                                do {
                                    if let jsonData = try json["data"] as? [[String: AnyObject]]{
                                        //print("jsonData : \(jsonData)")
                                        for data in jsonData {
                                            let info = personalRecordInfo()
                                            
                                            info.id = (data["id"] as? String)!
                                            info.telno = (data["tel"] as? String)!
                                            info.name = (data["name"] as? String)!
                                            info.date = (data["date"] as? String)!
                                            info.gameday = (data["gameday"] as? String)!
                                            info.gole = (data["gole"] as? String)!
                                            info.assist = (data["assist"] as? String)!
                                            info.mvp  = (data["mvp"] as? String)!
                                            info.result = (data["result"] as? String)!
                                            info.check = (data["check"] as? String)!
                                            info.checkdate = (data["checkdate"] as? String)!
                                            
                                            self.personalInfos.append(info)
                                            self.gameDay = info.gameday
                                      
                                            //self.recordStat
                                            switch info.result {
                                                case "Y"  : stat.check = stat.check + 1
                                                case "Y2" : stat.fullCheck = stat.fullCheck + 1
                                                case "N"  : stat.noCheck = stat.noCheck + 1
                                                case "X"  : stat.falseCheck = stat.falseCheck + 1
                                                case "X2" : stat.notCheck = stat.notCheck + 1
                                                default : break
                                            }
                                            stat.gole = stat.gole + Int(info.gole)!
                                            stat.assist = stat.assist + Int(info.assist)!
                                            if(info.mvp != "0") {
                                                stat.mvp = stat.mvp + 1
                                            }
                                            
                                        }
                                        self.recordStat = stat
                                    }
                                }catch let error as NSError {
                                    print("no data or data null")
                                }

                                
                            case .add :
                                var info = personalRecordInfo()
                                info = self.personalInfo
                                self.personalInfos.insert(info, at: 0)
                                
                            case .edit :
                                var info = personalRecordInfo()
                                info = self.personalInfo
                                self.personalInfos[self.selectIndex] = info
                                
                            case .delete :
                                self.personalInfos.remove(at: self.selectIndex)
                            }
                            
                        } catch {
                            print("error: parsing")
                            isFail = true
                        }
                        //self.refreshControl?.endRefreshing()
                        
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
                
                if(isFail){
                    self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                } else {
                    if (self.personalInfos.count >= 1){
                        self.headerTitle = "풀참:\(self.recordStat.fullCheck)   " +
                            "참석:\(self.recordStat.check)   " +
                            "불참:\(self.recordStat.noCheck)   " +
                            "구라:\(self.recordStat.falseCheck)   " +
                            "쌩까:\(self.recordStat.notCheck)   " +
                            "골:\(self.recordStat.gole)   " +
                            "도움:\(self.recordStat.assist)   " +
                            "우수:\(self.recordStat.mvp)   "
                    } else {
                        self.headerTitle = "검색 결과가 없습니다."
                        self.displayAlertMessage("검색 결과가 없습니다.")
                    }
                    self.tableView.reloadData()
                }

            })
        };
        task.resume();
    }
    
    
    func displayAlertMessage(_ userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertActionStyle.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
        
    }

}
