//
//  MemberInfoDetailViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 5. 12..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit
import Foundation
import MessageUI

class MemberInfoDetailViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var telButton: UIButton!

    var member = userInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = member.name
        telButton.setTitle(member.telno, for: UIControlState())
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func telButtonClick(_ sender: AnyObject) {
        
        let confirm = UIAlertController(title: "스톰 \(self.member.name)", message: "\(self.member.telno)", preferredStyle: UIAlertControllerStyle.actionSheet )
        let telnumber = self.member.telno.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        confirm.addAction(UIAlertAction(title: "전화걸기", style: UIAlertActionStyle.default, handler: { action in
            if let phoneCallURL: URL = URL(string: "tel://\(telnumber)") {
                let application: UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)){
                    application.openURL(phoneCallURL)
                } else {
                    self.displayAlertMessage("전화를 연결할 수 없습니다.")
                    print("no permision")
                }
            }
        }))
        confirm.addAction(UIAlertAction(title: "메세지 보내기", style: UIAlertActionStyle.default, handler: { action in
            if (MFMessageComposeViewController.canSendText()) {
                let smsController = MFMessageComposeViewController()
                smsController.body = "[스톰]"
                smsController.recipients = [telnumber]
                smsController.messageComposeDelegate = self
                self.present(smsController, animated: true, completion: nil)

            } else {
                self.displayAlertMessage("메세지를 보낼 수 없습니다.")
                print("no permision")
            }
        }))
        confirm.addAction(UIAlertAction(title: "취소", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(confirm, animated:true, completion:nil);
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message Called, \(controller.recipients)")
        case MessageComposeResult.failed.rawValue:
            print("Message Failed, \(controller.recipients)")
        case MessageComposeResult.sent.rawValue:
            print("Message was sent, \(controller.recipients)")
            
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func displayAlertMessage(_ userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertControllerStyle.alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertActionStyle.default, handler:nil);
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
