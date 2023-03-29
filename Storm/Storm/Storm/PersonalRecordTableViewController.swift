//
//  PersonalRecordViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 19..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class personalRecordInfo {
    var gameday: String = ""
    var name: String = ""
    var gole: String = "0"
    var assist: String = "0"
    var result: String = ""
    var mvp: String = "-"
    var date: String = ""
    var telno: String = ""
    var id: String = ""
    var check: String = ""
    var checkdate: String = ""
}


class PersonalRecordTableViewController: UITableViewController, UITextFieldDelegate {
   
    enum workType :Int {
        case read = 0
        case add = 1
        case edit = 2
        case delete = 3
        case list = 4
    }
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    
    let cellTableIdentifier = "PersonalRecordListCell"
    let headerTableIdentifier = "PersonalRecordHeaderCell"
    
    var dateFormatter = DateFormatter()
    let urlString: String = "http://www.acstorm.net/"
    var personalInfos = [personalRecordInfo]()
    var memberInfos = [userInfo]()
    var loading = UIActivityIndicatorView()
    var selectIndex = 0
    var headerTitle: String?
    var selectPersonalInfo: personalRecordInfo!
    let processStat = workType.read
    var deleteIndex: IndexPath!
    var winCount: Int = 0
    var lostCount: Int = 0
    var drawCount: Int = 0
    var lastsundaydate : Date?
    var gameDay: String?
    var lastsunday: String?
    
    var recordStat: RecordStat!
    var startDay: String = ""
    var endDay: String = ""
    var startDate: Date?
    var endDate: Date?
    var startDateEditing: Bool?
    var datePicker : UIDatePicker!
    var searchUserName: String = ""
    
    //var userInfos = UserInfoManager()
   
    override func viewDidLoad() {

        super.viewDidLoad()
        
        self.tableView.sectionHeaderHeight = 50
        self.tableView.sectionFooterHeight = 50
        
        self.personalInfos.removeAll()
        self.memberInfos.removeAll()

        self.navigationController?.navigationBar.topItem?.title = "팀원기록"
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshContorolPull), for: UIControl.Event.valueChanged)
        self.refreshControl?.tintColor = UIColor.orange
        
        //self.dateFormatter.locale = NSLocale(localeIdentifier: "ko_kr")
        //self.dateFormatter.timeZone = NSTimeZone(name: "KST")
        //self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        self.startDateField.delegate = self
        self.endDateField.delegate = self
        self.userNameField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.loading = UIActivityIndicatorView(style: .whiteLarge)
        self.loading.color = UIColor.orange
        self.loading.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 150, width: 100, height: 100)
        self.loading.hidesWhenStopped = true
        self.loading.startAnimating()
        self.view.addSubview(loading)
        
        self.searchButton.layer.cornerRadius = 3.0
        self.searchButton.clipsToBounds = true
        self.searchButton.layer.masksToBounds = true;
        
        self.selectIndex = -1
        self.startDay = ""
        self.endDay = ""
        
        self.infoRequest(.list)
        
        //All User Info
        //userInfos1.allUserInfoRequest()
        
    }
    
    func getLastSunday() {
        
        //지난 일요일 구하기  ( 오늘 weekday 값을 구해서 일요일(1)보다 큰값이 -1을 한 값만큼 뒤로 이동하면? 지난일요일이다.)
        let someDate = Date()
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps = (cal as NSCalendar).components([.year, .month, .day, .weekday], from: someDate)
        var offset = DateComponents()

        if(comps.weekday!  > 1){
            offset.day = (comps.weekday! - 1) * -1
        } else {
            offset.day = 0
        }
        lastsundaydate = (cal as NSCalendar).date(byAdding: offset, to: someDate, options: [])
        
        //let dateFormatter = NSDateFormatter()
        //dateFormatter.dateFormat = "yyyyMMdd"
        //self.lastsunday = dateFormatter.stringFromDate(self.lastsundaydate!)
        
        //
        dateFormatter.dateFormat = "yyyy년MM월dd일"
        self.startDateField.text = dateFormatter.string(from: self.lastsundaydate!)
        self.endDateField.text = dateFormatter.string(from: self.lastsundaydate!)

        dateFormatter.dateFormat = "yyyyMMdd"
        self.startDay = dateFormatter.string(from: self.lastsundaydate!)
        self.startDate = self.lastsundaydate!
        
        self.endDay = dateFormatter.string(from: self.lastsundaydate!)
        self.endDate = self.lastsundaydate!
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    
    //add 화면에서 cancel 버튼으로 돌아왔을때
    @IBAction func cancelAddView(_ segue: UIStoryboardSegue){
        print("cancelAddView")
        selectIndex = -1
        
    }
    
    
    //add 화면에서 done 버튼으로 돌아왔을때
    @IBAction func doneAddView(_ segue: UIStoryboardSegue){
        if let destinationView = segue.source as? PersonalRecordAddViewController {
            print("PersonalRecordAddViewController")
            self.selectPersonalInfo = destinationView.personalInfo
            print("id : \(self.selectPersonalInfo.id)")
            print("name : \(self.selectPersonalInfo.name)")
            print("date : \(self.selectPersonalInfo.date)")
            print("gameday : \(self.selectPersonalInfo.gameday)")
            print("gole : \(self.selectPersonalInfo.gole)")
            print("assist : \(self.selectPersonalInfo.assist)")
            print("mvp : \(self.selectPersonalInfo.mvp)")
            print("result : \(self.selectPersonalInfo.result)")
            
            if(selectIndex >= 0) {
              infoRequest(.edit)
              print("EDIT")
            } else {
              infoRequest(.add)
              print("ADD")
            }
        }
        selectIndex = -1
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.returnKeyType == UIReturnKeyType.search || textField.returnKeyType == UIReturnKeyType.done){
            if (textField.restorationIdentifier == "username"){
                refreshContorolPull()
            }
        }
        return true
    }
    
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        refreshContorolPull()
    }
    
    @objc func tapped() {
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
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
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
        self.datePicker.addTarget(self, action: #selector(datePickerSelected), for: UIControl.Event.valueChanged)
        
    }
    
    @objc func todayButtonTapped() {
        self.datePicker.date = Date()
        datePickerSelected(self.datePicker)
    }
    
    @objc func queryButtonTapped() {
        refreshContorolPull()
        self.view.endEditing(true)
    }
    
    
    @objc func datePickerSelected(_ datePic: UIDatePicker) {
        
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
    
    @objc func refreshContorolPull() {
        self.loading.startAnimating()
        
        if (self.startDay == "" && self.endDay == "") {
            getLastSunday()
        }
        
        infoRequest(.read)
    }
  
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.personalInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as? PersonalRecordTableViewCell
        
        let data = personalInfos[(indexPath as NSIndexPath).row]
        
        //이름으로 검색중이면 이름표시가 아닌 날짜표시
//        let nameFont = UIFont()
        if (self.searchUserName != "") {
            cell!.name.font = UIFont(name: (cell!.name.font?.fontName)!, size: 12)
            cell!.name.text = data.gameday
        } else {
            cell!.name.font = UIFont(name: (cell!.name.font?.fontName)!, size: 14)
            cell!.name.text = data.name
        }
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
        
        //user profile image
        if let uInfo = userInfos.getMember(id: data.id) {
            let photoURL = uInfo.photoURL
            
            if (photoURL != nil) {
                if let image = photoURL?.cachedImage {
                    print("cached image")
                    cell!.profileImage.image = image
                    cell!.profileImage.alpha = 1
                } else {
                    cell!.profileImage.alpha = 1
                    photoURL?.downImage{ image in
                        cell!.profileImage.image = image
                        UIView.animate(withDuration: 0.5, animations: {
                            cell!.profileImage.alpha = 1
                        })
                        print("download image")
                    }
                }
            } else {
                cell!.profileImage.image = uInfo.profileImage
                cell!.profileImage.alpha = 1
            }
        }
        
        return cell!
    }
    
   
    //선택되었을때 선택row 정보확인후 화면 전환 처리
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            
            //edit
            if (self.selectIndex >= 0) {
                selectPersonalInfo = personalInfos[selectIndex]
                destinationView.personalInfo = selectPersonalInfo
                destinationView.adding = false
            } else {
                destinationView.adding = true
                destinationView.members = memberInfos
            }

        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let vw = UIView() //frame: CGRect(x:0, y:0, width:self.tableView.frame.size.width, height: 50))
            vw.backgroundColor = UIColor.white
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
            titleLabel.textAlignment = NSTextAlignment.center
            if (self.searchUserName != "") {
                titleLabel.font = UIFont(name: (titleLabel.font?.fontName)!, size: 12)
            }
            titleLabel.text = headerTitle
            
            vw.addSubview(titleLabel)
            
            return vw
        }
        return nil
    }
 
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            selectPersonalInfo = personalInfos[(indexPath as NSIndexPath).row]
            deleteIndex = indexPath
            print("DELETE \(selectPersonalInfo.name)")
            infoRequest(.delete)
        } else if editingStyle == .insert {
            print("end Insert")
        } else if editingStyle == .none {
            print("end None")
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.selectIndex = -1
        print("end Editing")
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
        let userName: String = self.userNameField.text!
        self.searchUserName = userName.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let myUrl: URL = URL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        
        switch type {
            case .read  :
                if (self.searchUserName != "") {
                    postString = "worktype=R&destday=\(self.startDay)&destdayend=\(self.endDay)&user_name=\(self.searchUserName)"
                } else {
                    postString = "worktype=R&destday=\(self.startDay)&destdayend=\(self.endDay)"
                }
                
            case .add   : postString = "worktype=C&user_id=\(selectPersonalInfo.id)&user_name=\(selectPersonalInfo.name)&destday=\(selectPersonalInfo.date)&gole=\(selectPersonalInfo.gole)&assist=\(selectPersonalInfo.assist)&mvp=\(selectPersonalInfo.mvp)&result=\(selectPersonalInfo.result)&check=\(selectPersonalInfo.check)"
                
            case .edit  : postString = "worktype=U&user_id=\(selectPersonalInfo.id)&user_name=\(selectPersonalInfo.name)&destday=\(selectPersonalInfo.date)&gole=\(selectPersonalInfo.gole)&assist=\(selectPersonalInfo.assist)&mvp=\(selectPersonalInfo.mvp)&result=\(selectPersonalInfo.result)"
                
            case .delete: postString = "worktype=D&user_id=\(selectPersonalInfo.id)&destday=\(selectPersonalInfo.date)"
            
            case .list  : postString = "worktype=M"
        }
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        var isFail: Bool = false
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                print("error=\(error)");
                self.refreshControl?.endRefreshing()
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
                            case .list :
                                self.memberInfos.removeAll()
                                
                                do {
                                    if let jsonData = json["data"] as? [[String: AnyObject]]{
                                        for data in jsonData {
                                            let info = userInfo()
                                            
                                            info.id = (data["id"] as? String)!
                                            info.name = (data["name"] as? String)!
                                            info.telno = (data["tel"] as? String)!
                                            info.department = (data["department"] as? String)!
   
                                            self.memberInfos.append(info)
                                        }
                                        print("members info get success")
                                    }
                                }catch let error as NSError {
                                    print("no data or data null")
                                }
                                
                            case .read :
                                let stat = RecordStat()
                                self.recordStat = stat
                                self.personalInfos.removeAll()
                                
                                do {
                                    if let jsonData = json["data"] as? [[String: AnyObject]]{
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
                                        print("personals info get success")
                                    }
                                }catch let error as NSError {
                                    print("no data or data null")
                                }
                            
                            case .add :
                                var info = personalRecordInfo()
                                info = self.selectPersonalInfo
                                self.personalInfos.insert(info, at: 0)
                                
                            case .edit :
                                var info = personalRecordInfo()
                                info = self.selectPersonalInfo
                                self.personalInfos[self.selectIndex] = info
                                self.selectIndex = -1
                                
                            case .delete :
                                self.personalInfos.remove(at: self.deleteIndex.row)
                                self.deleteIndex = nil
                                self.selectIndex = -1
                            }
                            
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
                self.refreshControl?.endRefreshing()
                
                if(isFail){
                    self.displayAlertMessage("정보 확인 실패, 잠시후 재시도 하세요.")
                } else {
                    if (type == .read) {
                        if (self.personalInfos.count > 0) {
                            if (self.searchUserName != "") {
                                self.headerTitle = "풀참:\(self.recordStat.fullCheck)   " +
                                    "참석:\(self.recordStat.check)   " +
                                    "불참:\(self.recordStat.noCheck)   " +
                                    "구라:\(self.recordStat.falseCheck)   " +
                                    "쌩까:\(self.recordStat.notCheck)   " +
                                    "골:\(self.recordStat.gole)   " +
                                    "도움:\(self.recordStat.assist)   " +
                                    "우수:\(self.recordStat.mvp)   "
                            } else {
                                self.headerTitle = self.gameDay! + " 전체 개인기록 현황"
                                self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let nowTime = self.dateFormatter.string(from: Date())
                                self.refreshControl?.attributedTitle = NSAttributedString(string: "마지막 확인 시간 : \(nowTime)")
                            }
                        } else {
                            self.headerTitle = "검색 결과가 없습니다."
                            self.displayAlertMessage("검색 결과가 없습니다.")
                        }

                    } else if (type == .list) {
                        self.refreshContorolPull()
                    }
                    self.tableView.reloadData()
                    //self.tableView.editing = false
                    self.isEditing = false
                    
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
