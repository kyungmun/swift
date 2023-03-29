//
//  TeamRecordAddViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 8..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit
//import WWCalendarTimeSelector

class TeamRecordAddViewController: UITableViewController, UITextFieldDelegate, WWCalendarTimeSelectorProtocol {
    
    let urlString: String = "http://www.acstorm.net/"
    
    @IBOutlet weak var gameDateButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var addResult: Bool = false
    var addGameDay: String = ""
    var teamInfo = teamRecordInfo()
    var adding: Bool = true
    var selectGameDate: Date = Date()
    var dateFormatter = DateFormatter()
    
    @IBOutlet weak var gameSegment: UISegmentedControl!
    @IBOutlet weak var teamNameField: UITextField!
    @IBOutlet weak var gameGroundField: UITextField!
    @IBOutlet weak var goleField: UITextField!
    @IBOutlet weak var lostGoleField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (self.adding) {
            self.navigationController?.navigationBar.topItem?.title = "새로운 팀기록"
            self.gameSegment.isEnabled = true
        } else {
            self.navigationController?.navigationBar.topItem?.title = "팀기록 편집"

        }
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.saveButton.isEnabled = false
        
        teamNameField.delegate = self
        gameGroundField.delegate = self
        goleField.delegate = self
        lostGoleField.delegate = self
        
        teamNameField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        gameGroundField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        goleField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        lostGoleField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        dateFormatter.dateFormat = "yyyy년MM월dd일"
        
        teamInfoShow()
       
        
        // Do any additional setup after loading the view.
    }
    
    
    func teamInfoShow() {
        //추가할 때는 기본
        //수정할 때는 선택되서 넘어온 값을 표시한다.
        if (self.adding) {
            gameDateButton.setTitle(dateFormatter.string(from: selectGameDate), for: UIControlState())
            teamNameField.text = ""
            gameGroundField.text = ""
            goleField.text = "0"
            lostGoleField.text = "0"
        } else {
            gameDateButton.setTitle(self.teamInfo.gameday, for: UIControlState())
            teamNameField.text = self.teamInfo.teamname
            gameGroundField.text = self.teamInfo.ground
            goleField.text = self.teamInfo.gole
            lostGoleField.text =  self.teamInfo.lostgole
        }
    }
    
    
    func dismissKeyboard(){
        self.view.endEditing(true)
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
        dateFormatter.dateFormat = "yyyy년MM월dd일"
        gameDateButton.setTitle(dateFormatter.string(from: date), for: UIControlState())
        dateFormatter.dateFormat = "yyyyMMdd"
        addGameDay = dateFormatter.string(from: date)
        selectGameDate = date
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        self.saveButton.isEnabled = !(self.teamNameField.text?.isEmpty)! &&
            !(self.gameGroundField.text?.isEmpty)! &&
            !(self.goleField.text?.isEmpty)! &&
            !(self.lostGoleField.text?.isEmpty)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    //세그 이동전에 저장버튼이면 저장 할 데이터를 변수에 담아놓기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        if (sender as! UIBarButtonItem) == saveButton {
            addResult = true
            //입력된 값을 팀정보에 넣는다.
            teamInfo.teamname = teamNameField.text!
            teamInfo.gameday = (gameDateButton.titleLabel?.text)!
            teamInfo.date = addGameDay
            teamInfo.gole = goleField.text!
            teamInfo.lostgole = lostGoleField.text!
            teamInfo.ground = gameGroundField.text!
        
            if (teamInfo.gole > teamInfo.lostgole){
                teamInfo.result = "W"
            } else if (teamInfo.gole < teamInfo.lostgole){
                teamInfo.result = "L"
            } else if (teamInfo.gole == teamInfo.lostgole){
                teamInfo.result = "U"
            }
        }
    }
 
    @IBAction func gameSegmentTapped(_ sender: AnyObject) {
        switch sender.selectedSegmentIndex {
            case 0: goleField.text = "0"
                    lostGoleField.text = "0"
                    teamNameField.text = ""
            case 1: goleField.text = "0"
                    lostGoleField.text = "0"
                    teamNameField.text = "자체경기"
            default: break;
            
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
            case 1 :
                switch (indexPath as NSIndexPath).row {
                    case 0 : gameDateButton.becomeFirstResponder()
                    case 1 : teamNameField.becomeFirstResponder()
                    case 2 : gameGroundField.becomeFirstResponder()
                    default : break
                }
            case 2:
                switch (indexPath as NSIndexPath).row {
                    case 0 : goleField.becomeFirstResponder()
                    case 1 : lostGoleField.becomeFirstResponder()
                    default : break
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
