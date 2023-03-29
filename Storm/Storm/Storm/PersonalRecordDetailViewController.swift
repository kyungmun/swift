//
//  PersonalRecordDetailViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 10..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class PersonalRecordDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gameDayLabel: UILabel!
    @IBOutlet weak var gameResultLabel: UILabel!
    @IBOutlet weak var gameGroundLabel: UILabel!
    
    var  personalInfo = personalRecordInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        nameLabel.text = personalInfo.name
        gameDayLabel.text = personalInfo.gameday
        gameGroundLabel.text = personalInfo.gole
        
        /*
        switch (personalInfo.result) {
            case "W" : gameResultLabel.text =  "승 (\(personalInfo.gole) vs \(personalInfo.lostgole))"
            gameResultLabel.textColor = UIColor.blueColor()
            
            case "L" : gameResultLabel.text = "패 (\(personalInfo.gole) vs \(personalInfo.lostgole))"
            gameResultLabel.textColor = UIColor.redColor()
            
            case "U" : gameResultLabel.text = "무 (\(personalInfo.gole) vs \(personalInfo.lostgole))"
            gameResultLabel.textColor = UIColor.grayColor()
            
            default: gameResultLabel.text = "-"
            gameResultLabel.textColor = UIColor.grayColor()
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //편집 화면에서 cancel 버튼으로 돌아왔을때
    @IBAction func cancelEditView(_ segue: UIStoryboardSegue){
        print("cancelEditView")
        

    }
    
    
    //편집 화면에서 done 버튼으로 돌아왔을때
    @IBAction func doneEditView(_ segue: UIStoryboardSegue){
        print("doneEditView")
        
        
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
