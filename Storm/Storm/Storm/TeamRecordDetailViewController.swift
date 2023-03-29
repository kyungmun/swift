//
//  TeamRecordDetailViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 10..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class TeamRecordDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var gameDayLabel: UILabel!
    @IBOutlet weak var gameResultLabel: UILabel!
    @IBOutlet weak var gameGroundLabel: UILabel!
    
    var teamInfo = teamRecordInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        nameLabel.text = teamInfo.teamname
        gameDayLabel.text = teamInfo.gameday
        gameGroundLabel.text = teamInfo.ground
        
        switch (teamInfo.result) {
            case "W" : gameResultLabel.text =  "승 (\(teamInfo.gole) vs \(teamInfo.lostgole))"
            gameResultLabel.textColor = UIColor.blue
            
            case "L" : gameResultLabel.text = "패 (\(teamInfo.gole) vs \(teamInfo.lostgole))"
            gameResultLabel.textColor = UIColor.red
            
            case "U" : gameResultLabel.text = "무 (\(teamInfo.gole) vs \(teamInfo.lostgole))"
            gameResultLabel.textColor = UIColor.gray
            
            default: gameResultLabel.text = "-"
            gameResultLabel.textColor = UIColor.gray
            
        }

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
