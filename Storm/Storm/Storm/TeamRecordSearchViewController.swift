//
//  TeamRecordSearchViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 7. 15..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class TeamRecordSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    enum workType :Int {
        case read = 0
        case add = 1
        case edit = 2
        case delete = 3
    }
    
    let cellTableIdentifier = "TeamRecordListCell2"
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var endDateField: UITextField!
    @IBOutlet weak var teamNameField: UITextField!
    
    var dateFormatter = DateFormatter()
    let urlString: String = "http://www.acstorm.net/"
    var teamInfos = [teamRecordInfo]()
    var loading = UIActivityIndicatorView()
    var selectTeamIndex = 0
    var headerTitle: String?
    var teamInfo: teamRecordInfo!
    var searchTeamInfos = [teamRecordInfo]()
    
    let processStat = workType.read
    var deleteTeamIndex: IndexPath!
    var winCount: Int = 0
    var lostCount: Int = 0
    var drawCount: Int = 0
    
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
        
        self.teamInfos.removeAll()
        
        self.navigationController?.navigationBar.topItem?.title = "팀기록2"
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //self.navigationItem.title = "팀기록 검색"
        
        self.startDateField.delegate = self
        self.endDateField.delegate = self
        self.teamNameField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.loading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.loading.color = UIColor.orange
        self.loading.frame = CGRect(x: self.view.frame.midX - 50, y: self.view.frame.midY - 150, width: 100, height: 100)
        self.loading.hidesWhenStopped = true
        self.loading.startAnimating()
        self.view.addSubview(loading)
        
        self.startDay = ""
        self.endDay = ""
        refreshContorolPull()
        
    }
    
    func refreshContorolPull() {
        
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
        
        winCount = 0
        lostCount = 0
        drawCount = 0
        
        infoRequest(.read)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.returnKeyType == UIReturnKeyType.search || textField.returnKeyType == UIReturnKeyType.done){
            if (textField.restorationIdentifier == "teamname"){
                refreshContorolPull()
            }
        }
        return true
    }
    
    func tapped() {
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
        self.view.endEditing(true)
        refreshContorolPull()
    }
    
    
    func datePickerSelected(_ datePic: UIDatePicker) {
        //let dateFormatter = NSDateFormatter()
        
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
    
    
    
    //add 화면에서 cancel 버튼으로 돌아왔을때
    @IBAction func cancelAddView(segue: UIStoryboardSegue){
        print("cancelTeamAddView")
        selectTeamIndex = -1
    }
    
    
    //add 화면에서 done 버튼으로 돌아왔을때
    @IBAction func doneAddView(segue: UIStoryboardSegue){
        print("doneTeamAddView")
        if let destinationView = segue.source as? TeamRecordAddViewController {
            self.teamInfo = destinationView.teamInfo
            print("date : \(destinationView.teamInfo.date)")
            print("gameday : \(destinationView.teamInfo.gameday)")
            print("teamname : \(destinationView.teamInfo.teamname)")
            print("gole : \(destinationView.teamInfo.gole)")
            print("lostgole : \(destinationView.teamInfo.lostgole)")
            print("ground : \(destinationView.teamInfo.ground)")
            //infoRequest(.ADD)
        }
        
    }
   
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (tableView == self.searchDisplayController?.searchResultsTableView){
            return self.searchTeamInfos.count
        } else {
            return self.teamInfos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath) as? TeamRecordTableViewCell
        
        var data : teamRecordInfo
        if (tableView == self.searchDisplayController?.searchResultsTableView){
            data = self.searchTeamInfos[(indexPath as NSIndexPath).row]
        } else {
            data = self.teamInfos[(indexPath as NSIndexPath).row]
        }
            
        cell!.teamNameLabel.text = data.teamname
        cell!.gameDayLabel.text = data.gameday
        cell!.gameGroundLabel.text = data.ground
        
        switch (data.result) {
        case "W" : cell?.resultLabel.text =  "승 (\(data.gole) vs \(data.lostgole))"
        cell?.resultLabel.textColor = UIColor.blue
            
        case "L" : cell?.resultLabel.text = "패 (\(data.gole) vs \(data.lostgole))"
        cell?.resultLabel.textColor = UIColor.red
            
        case "U" : cell?.resultLabel.text = "무 (\(data.gole) vs \(data.lostgole))"
        cell?.resultLabel.textColor = UIColor.gray
            
        default: cell?.resultLabel.text = "-"
        cell?.resultLabel.textColor = UIColor.gray
            
        }
        
        return cell!
    }
    
    
    //선택되었을때 선택row 정보확인후 화면 전환 처리
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.indexPathForSelectedRow!
        if let _ = tableView.cellForRow(at: indexPath) {
            
            var data : teamRecordInfo
            if (tableView == self.searchDisplayController?.searchResultsTableView){
                data = self.searchTeamInfos[(indexPath as NSIndexPath).row]
            } else {
                data = self.teamInfos[(indexPath as NSIndexPath).row]
            }
            print("name: \(data.teamname)")
            
            selectTeamIndex = (indexPath as NSIndexPath).row
            self.performSegue(withIdentifier: "teamRecordEditSegue", sender: self)
        }
        
    }
    
    
    //row select 해서 화면 전환시 값 넘겨주기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("prepareForSegue")
        if (segue.identifier == "teamRecordEditSegue"){
           
            let DestViewController = segue.destination as! UINavigationController
            let destinationView = DestViewController.topViewController as! TeamRecordAddViewController

            if (self.selectTeamIndex >= 0) {
                teamInfo = teamInfos[selectTeamIndex]
                destinationView.teamInfo = teamInfo
                destinationView.adding = false
            }
        }
    }
   
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0) {
            let vw = UIView() //frame: CGRect(x:0, y:0, width:self.tableView.frame.size.width, height: 50))
            vw.backgroundColor = UIColor.white
            
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 50))
            titleLabel.textAlignment = NSTextAlignment.center
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
            selectTeamIndex = (indexPath as NSIndexPath).row
            teamInfo = teamInfos[(indexPath as NSIndexPath).row]
            deleteTeamIndex = indexPath
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            infoRequest(.delete)
        } else if editingStyle == .insert {
            
            // Create a new instance of the appropriate class, insert it into the array, and add a new row toCthe table view
        }
    }
    
    
    // MARK: - search
    
    func filterContetnForSearchText(_ searchText: String, scope: String = "Title") {
        
        self.searchTeamInfos = self.teamInfos.filter({( data : teamRecordInfo) -> Bool in
            
            let categoryMatch = (scope == "Title")
            let stringMatch = data.teamname.range(of: searchText)
            
            return categoryMatch && (stringMatch != nil)
        })
    }
    
    func existData(_ gameday: String) -> Int {
        if (self.teamInfos.count > 0) {
            for i in 0 ... teamInfos.count-1 {
                if (self.teamInfos[i].gameday == gameday) {
                    return i
                }
            }
        }
        return -1
    }
    
    //checkValue, profileimage, destday re-confirm
    func infoRequest(_ type: workType) {

        let subUrl: String = "xe/work/mobile_team.php"
        var postString: String = ""
        let teamName: String = teamNameField.text!
        let newTeamName = teamName.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let myUrl: URL = URL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        
        switch type {
        case .read  :
            if (newTeamName != "") {
                postString = "worktype=R&destday=\(startDay)&destdayend=\(endDay)&teamname=\(newTeamName)"
            } else {
                postString = "worktype=R&destday=\(startDay)&destdayend=\(endDay)"
            }
            
        case .add   : break
            
        case .edit  : postString = "worktype=E&teamname=\(teamInfo.teamname)&destday=\(teamInfo.date)&gole=\(teamInfo.gole)&lostgole=\(teamInfo.lostgole)&ground=\(teamInfo.ground)"
            
        case .delete: postString = "worktype=D&destday=\(teamInfo.date)"
            
        }
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        var isFail: Bool = false
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                print("error=\(error)");
                //self.refreshControl?.endRefreshing()
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
                                self.teamInfos.removeAll()
                                if let jsonData = json["data"] as? [[String: AnyObject]]{
                                    for data in jsonData {
                                       
                                        let info = teamRecordInfo()
                                        
                                        info.teamname = (data["name"] as? String)!
                                        info.date = (data["date"] as? String)!
                                        info.gameday = (data["gameday"] as? String)!
                                        info.gole = (data["gole"] as? String)!
                                        info.lostgole = (data["lostgole"] as? String)!
                                        info.result = (data["result"] as? String)!
                                        info.ground = (data["ground"] as? String)!
                                        
                                        self.teamInfos.append(info)
                                        
                                        switch info.result {
                                        case "W" : self.winCount = self.winCount + 1
                                        case "L" : self.lostCount = self.lostCount + 1
                                        case "U" : self.drawCount = self.drawCount + 1
                                        default : break
                                        }
                                    }
                                }
                            case .add :
                                var info = teamRecordInfo()
                                info = self.teamInfo
                                self.teamInfos.insert(info, at: 0)
                                switch info.result {
                                case "W" : self.winCount = self.winCount + 1
                                case "L" : self.lostCount = self.lostCount + 1
                                case "U" : self.drawCount = self.drawCount + 1
                                default : break
                                }
                                
                            case .edit :
                                var info = teamRecordInfo()
                                info = self.teamInfo
                                self.teamInfos[self.selectTeamIndex] = info
                                
                            case .delete :
                                switch self.teamInfo.result {
                                case "W" : self.winCount = self.winCount - 1
                                case "L" : self.lostCount = self.lostCount - 1
                                case "U" : self.drawCount = self.drawCount - 1
                                default : break
                                }
                                self.teamInfos.remove(at: self.selectTeamIndex)
                                //self.tableView.deleteRowsAtIndexPaths([self.deleteTeamIndex], withRowAnimation: .Fade)
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
                    if (self.teamInfos.count >= 1){
                      self.headerTitle = "[\(self.winCount) 승 : \(self.drawCount) 무 : \(self.lostCount) 패]"
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
