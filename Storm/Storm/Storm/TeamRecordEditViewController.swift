//
//  TeamRecordEditViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 10..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit

class TeamRecordEditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]


        self.navigationItem.setHidesBackButton(true, animated: false)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
