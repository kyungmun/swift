//
//  PersonalRecordAddViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 8..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit
//import WWCalendarTimeSelector

class PersonalRecordAddViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, WWCalendarTimeSelectorProtocol {
    
    let urlString: String = "http://www.acstorm.net/"
    


    @IBOutlet weak var gameDateButton: UIButton!
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var checkDateLabel: UILabel!
    @IBOutlet weak var checkValueLabel: UILabel!
    @IBOutlet weak var checkResultSegment: UISegmentedControl!
    @IBOutlet weak var mvpSwitch: UISwitch!
    @IBOutlet weak var goleField: UITextField!
    @IBOutlet weak var assistField: UITextField!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var addResult: Bool = false
    var addGameDay: String = ""
    var personalInfo = personalRecordInfo()
    var adding: Bool = true
    var selectGameDate: Date = Date()
    var dateFormatter = DateFormatter()
    var members = [userInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.adding) {
            self.navigationController?.navigationBar.topItem?.title = "새로운 개인기록"
            self.dateFormatter.dateFormat = "yyyy년MM월dd일"
            gameDateButton.setTitle(self.dateFormatter.string(from: selectGameDate), for: UIControlState())
        } else {
            self.navigationController?.navigationBar.topItem?.title = "개인기록 편집"
            dateFormatter.dateFormat = "yyyyMMdd"
            selectGameDate = dateFormatter.date(from: personalInfo.date)!
            gameDateButton.setTitle(personalInfo.gameday, for: UIControlState())
        }
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.saveButton.isEnabled = true
    
        goleField.delegate = self
        assistField.delegate = self
        
        goleField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        assistField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        let sleft = (Device.TheCurrentDeviceWidth - 15 - 70 - 15 - 51 - 15) / 2
        mvpSwitch.layer.frame.x = 100 + sleft
        
        if (self.adding) {
            self.saveButton.isEnabled = false
            let pickerView = UIPickerView()
            pickerView.backgroundColor = UIColor.white
            pickerView.delegate = self
            pickerView.dataSource = self
            userNameField.inputView = pickerView
        } else {
            userNameField.inputView = nil
        }
        
        personalInfoShow()
        
        
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return members.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return members[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.userNameField.text = members[row].name
        self.personalInfo.id = members[row].id
        self.personalInfo.name = members[row].name
        self.saveButton.isEnabled = true
    }
    
    @IBAction func gameDateTapped(_ sender: UIButton) {
        
        let selector = WWCalendarTimeSelector.instantiate()
        selector.delegate = self
        
        selector.optionTopPanelBackgroundColor = UIColor.black
        selector.optionSelectorPanelBackgroundColor = UIColor.orange
        selector.optionButtonFontColorDone = UIColor.orange
        selector.optionButtonFontColorCancel = UIColor.orange
        selector.optionButtonTitleDone = "확인"
        selector.optionButtonTitleCancel = "취소"
        
        selector.optionCurrentDate = selectGameDate

        present(selector, animated: true, completion: nil)
    }
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date) {
        self.dateFormatter.dateFormat = "yyyy년MM월dd일"
        gameDateButton.setTitle(self.dateFormatter.string(from: date), for: UIControlState())
        selectGameDate = date
        if (self.adding) {
            self.dateFormatter.dateFormat = "yyyy-MM-dd 00:00:00"
            checkDateLabel.text = self.dateFormatter.string(from: selectGameDate)
        }
    }
    
    
    
    func personalInfoShow() {
        //추가할 때는 기본적으로 이전 일요일 날짜로 해당 계정의 체크 정보를 조회해서 표시한다.
        //수정할 때는 선택되서 넘어온 값을 표시한다.
        if (self.adding) {
            self.personalInfo.check = "X"
            //userNameButton.titleLabel!.text = self.personalInfo.name
            userNameField.placeholder = "회원명"
            self.dateFormatter.dateFormat = "yyyy-MM-dd 00:00:00"
            checkDateLabel.text = self.dateFormatter.string(from: selectGameDate)
            
            switch self.personalInfo.check {
                case "Y" : checkValueLabel.text = "참석"
                case "N": checkValueLabel.text = "불참"
                default : checkValueLabel.text = "미정"
            }
            
            self.checkResultSegment.selectedSegmentIndex = 1
            
            mvpSwitch.isOn = false
            
        } else {
            gameDateButton.setTitle(self.personalInfo.gameday, for: UIControlState())
            userNameField.text = self.personalInfo.name
            userNameField.isEnabled = false
            checkDateLabel.text = self.personalInfo.checkdate
            
            switch self.personalInfo.check {
                case "Y" : checkValueLabel.text = "참석"
                case "N": checkValueLabel.text = "불참"
                default : checkValueLabel.text = "미정"
            }
            
            switch personalInfo.result {
                case "Y2" :
                    self.checkResultSegment.selectedSegmentIndex = 0
                case "Y" :
                    self.checkResultSegment.selectedSegmentIndex = 1
                case "N" :
                    self.checkResultSegment.selectedSegmentIndex = 2
                default: self.checkResultSegment.selectedSegmentIndex = 2
            }

            mvpSwitch.isOn = self.personalInfo.mvp != "0"
            goleField.text = self.personalInfo.gole
            assistField.text = self.personalInfo.assist
        }
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        //self.saveButton.enabled = !(self.teamNameField.text?.isEmpty)! &&
        //    !(self.gameGroundField.text?.isEmpty)! &&
        //    !(self.goleField.text?.isEmpty)! &&
        //    !(self.lostGoleField.text?.isEmpty)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //세그 이동전에 저장버튼이면 저장 할 데이터를 변수에 담아놓기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        
        if (sender as! UIBarButtonItem) == saveButton {
        //if sender === saveButton {
            addResult = true

            //입력된 값을 팀정보에 넣는다.
            personalInfo.checkdate = self.checkDateLabel.text!

            self.dateFormatter.dateFormat = "yyyyMMdd"
            addGameDay = self.dateFormatter.string(from: selectGameDate)
            
            personalInfo.date = addGameDay
            personalInfo.gameday = (gameDateButton.titleLabel?.text!)!
            
            personalInfo.gole = "0"
            if (goleField.text != "") {
                personalInfo.gole = goleField.text!
            }

            personalInfo.assist = "0"
            if (assistField.text != "") {
                personalInfo.assist = assistField.text!
            }
            
            personalInfo.mvp = "0"
            if (mvpSwitch.isOn) {
                personalInfo.mvp = "1"
            }
            
            switch checkResultSegment.selectedSegmentIndex {
                case 0 : personalInfo.result = "Y2"
                case 1 : personalInfo.result = "Y"
                case 2 : personalInfo.result = "N"
                default : personalInfo.result = "N"
            }
        }
    }
 
    @IBAction func resultSegChanged(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 2) {
            self.mvpSwitch.isOn = false
            self.goleField.text = "0"
            self.assistField.text = "0"
        }
        
    }
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
        }
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch (indexPath as NSIndexPath).section {
            case 0 :
                switch (indexPath as NSIndexPath).row {
                    case 0 : gameDateButton.becomeFirstResponder()
                    default : self.view.endEditing(true)
                }
            case 1 :
                switch (indexPath as NSIndexPath).row {
                    default : self.view.endEditing(true)
                }
            case 2:
                switch (indexPath as NSIndexPath).row {
                    case 2 : goleField.becomeFirstResponder()
                    case 3 : assistField.becomeFirstResponder()
                    default : self.view.endEditing(true)
                }
            default : break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func displayAlertMessage(_ userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertActionStyle.default, handler:nil);
        
        myAlert.addAction(okAction);
        self.present(myAlert, animated:true, completion:nil);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
