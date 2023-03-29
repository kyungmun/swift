//
//  LoginViewController.swift
//  Storm
//
//  Created by Vagrant on 2016. 4. 18..
//  Copyright © 2016년 Storm. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController, UITextFieldDelegate {

    let urlString: String = "http://www.acstorm.net/"
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var userIdText: UITextField!
    @IBOutlet weak var passwdText: UITextField!

    /*
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
 */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userIdText.delegate = self
        passwdText.delegate = self
        userIdText.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector:(#selector(LoginViewController.networkStatusChanged(_:))), name: NSNotification.Name(rawValue: ReachabilityStatusChangedNotification), object: nil)
        Reach().monitorReachabilityChanges()
        
        self.loginButton.layer.cornerRadius = 5.0
        self.loginButton.clipsToBounds = true
        self.loginButton.layer.masksToBounds = true;

        userIdText.isEnabled = true
        passwdText.isEnabled = true
        loginButton.isEnabled = true
        
        
        //UIApplication.sharedApplication().statusBarStyle = .LightContent
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {

        
        let logined = UserDefaults.standard.bool(forKey: "isLogged")
        if (logined == true) {
            self.performSegue(withIdentifier: "MainPageView", sender: self)
        }
        
        
        let status = Reach().connectionStatus()
        switch status {
        case .unknown, .offline:
            print("Not connected")
        case .online(.wwan):
            print("Connected via WWAN")
        case .online(.wiFi):
            print("Connected via WiFi")
        }
        

    }
    
    /*
    @IBOutlet weak var fadeBox: UIView!
    
    @IBAction func fadeTest(sender: AnyObject) {
        if (fadeBox.alpha == 0) {
            fadeBox.fadeIn()
        } else {
            fadeBox.fadeOut(1.0, delay: 2.0)
        }
    }
 */
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.returnKeyType == UIReturnKeyType.next) {
            passwdText.becomeFirstResponder()
        } else if (textField.returnKeyType == UIReturnKeyType.go || textField.returnKeyType == UIReturnKeyType.done){
            if (textField.restorationIdentifier == "password"){
                loginButtonTapped(textField)
            }
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    
    
    @objc func networkStatusChanged(_ notification: Notification) {
        //let userInfo = notification.userInfo
        //print(userInfo)
    }
    
    
    @IBAction func loginButtonTapped(_ sender: AnyObject) {

        
        if(userIdText.text!.isEmpty){
            self.userIdText.becomeFirstResponder()
            return;
        }
        
        if(passwdText.text!.isEmpty){
            self.passwdText.becomeFirstResponder()
            return;
        }
        
        userIdText.isEnabled = false
        passwdText.isEnabled = false
        loginButton.isEnabled = false
        
        let status = Reach().connectionStatus()

        switch status {
        case .unknown, .offline:
            displayAlertMessage("네트워크를 사용할 수 없습니다.")
            userIdText.isEnabled = true
            passwdText.isEnabled = true
            loginButton.isEnabled = true
            return
        case .online(.wwan), .online(.wiFi):
            login_request(uId : userIdText.text!, uPass: passwdText.text!)
            view.endEditing(true)
        }
    }

    
    func login_request(uId userid: String, uPass userPassword: String){
       
        EZLoadingActivity.Settings.SuccessColor = UIColor.blue
        EZLoadingActivity.show("로그인중...", disableUI: false)
 
        UserDefaults.standard.set(false, forKey: "isLogged")
        
        let subUrl: String = "xe/work/mobile_check.php"
        
        let myUrl: URL = URL(string: urlString + subUrl)!
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "POST"
        
        //HTTPBody request is POST
        let postString = "work_type=L&user_id=" + userid + "&user_password=" + userPassword.md5()
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        var alertMessage: String?
        var isFail: Bool = false
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                //print("error=\(error)");
                EZLoadingActivity.hide()
                DispatchQueue.main.async(execute: {
                    self.displayAlertMessage("로그인 실패 code:0")

                    self.userIdText.isEnabled = true
                    self.passwdText.isEnabled = true
                    self.loginButton.isEnabled = true
                });
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String?
                    //print("result: \(resultValue)")
                    
                    
                    if(resultValue != nil && resultValue == "success"){
                        //login success
                        let userId = json["userid"] as! String?
                        let userName = json["username"] as! String?
                        let destDay = json["destday"] as! String?
                        let destDayText = json["destdaytext"] as! String?
                        let checkValue = json["check"] as! String?
                        let userSrl = json["usersrl"] as! String?
                        let profileImage = json["profileimage"] as! String
                        let isAdmin = json["isadmin"] as! Bool
                        let isManager = json["ismanager"] as! Bool
                        
                        UserDefaults.standard.set(userId, forKey: "userId")
                        UserDefaults.standard.set(userName, forKey: "userName")
                        UserDefaults.standard.set(userSrl, forKey: "userSrl")
                        UserDefaults.standard.set(destDay, forKey: "destDay")
                        UserDefaults.standard.set(destDayText, forKey: "destDayText")
                        UserDefaults.standard.set(checkValue, forKey: "checkValue")
                        UserDefaults.standard.set(profileImage, forKey: "profileImage")
                        UserDefaults.standard.set(isAdmin, forKey: "isAdmin")
                        UserDefaults.standard.set(isManager, forKey: "isManager")
                        UserDefaults.standard.set(true, forKey: "isLogged")
                        UserDefaults.standard.synchronize()
                        
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let mainViewController = storyboard.instantiateViewController(withIdentifier: "MainView") as! UITabBarController
                        self.present(mainViewController, animated: true, completion: nil)
                    } else if (resultValue != nil && resultValue == "submember") {
                        isFail = true
                        alertMessage = "준회원은 사용을 제한합니다."
                    
                    } else {
                        //let jsonStr = NSString(data:data!, encoding: NSUTF8StringEncoding)
                        //print("error:\(jsonStr)")
                        isFail = true
                        alertMessage = "ID/비밀번호를 확인하세요."
                    }
                } else {
                    //let jsonStr = NSString(data:data!, encoding: NSUTF8StringEncoding)
                    //print("error:\(jsonStr)")
                    isFail = true
                    alertMessage = "로그인 실패, Code:1"
                }
            
            } catch let error as NSError {
                //let jsonStr = NSString(data:data!, encoding: NSUTF8StringEncoding)
                //print("error:\(jsonStr)")
                isFail = true
                alertMessage = "로그인 실패, code:2"
            }
            
            DispatchQueue.main.async(execute: {
                EZLoadingActivity.hide()
                if (isFail) {
                    self.displayAlertMessage(alertMessage!)
                
                    self.userIdText.isEnabled = true
                    self.passwdText.isEnabled = true
                    self.loginButton.isEnabled = true
                }
            });
            
        };
        task.resume();
    }
    
    func displayAlertMessage(_ userMessage: String) {
        let myAlert = UIAlertController(title:"스톰", message:userMessage, preferredStyle: UIAlertController.Style.alert);
        
        let okAction = UIAlertAction(title:"확인", style:UIAlertAction.Style.default, handler:nil);
        
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
