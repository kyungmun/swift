//
//  UserInfoManager.swift
//  Storm
//
//  Created by kyungmun on 06/04/2017.
//  Copyright © 2017 Storm. All rights reserved.
//

import UIKit
import Foundation

class userInfo {
    var id: String = ""
    var name: String = ""
    var telno: String = ""
    var department: String = ""
    var checkValue: String = ""
    var checkTime: String = ""
    var photoUrlPath: String = ""
    var deviceUrlPath: String = ""
    var photoURL: URL! = nil
    var playRatio: Float = 0.0
    var profileImage: UIImage = UIImage(named:"Contacts-50.png")!
    var changed: Bool = false
}



fileprivate var ProfileImageCache = NSCache<AnyObject, UIImage>()
extension URL {
    typealias ImageCacheCompletion = (UIImage) -> Void
    var cachedImage: UIImage? {
        return ProfileImageCache.object(forKey: self.absoluteString as AnyObject)
    }
    
    func downImage(completion: @escaping ImageCacheCompletion) {
        let task = URLSession.shared.dataTask(with: self, completionHandler: {
            data, response, error in
            if error == nil {
                if let data = data, let image = UIImage(data: data) {
                    //print("self.absoluteString \(self.absoluteString)")
                    ProfileImageCache.setObject((image as? UIImage)!, forKey: self.absoluteString as AnyObject, cost: data.count)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        })
        task.resume()
    }
}


class UserInfoManager {

    let urlString: String = "http://www.acstorm.net/"
    var members = [userInfo]()
    
    func getMember(id: String) -> userInfo? {
        if (self.members.count > 0) {
            for i in 0 ... members.count-1 {
                if (self.members[i].id == id) {
                    return self.members[i]
                }
            }
        }
        return nil
    }

    func existMember(_ id: String) -> Int {
        if (self.members.count > 0) {
            for i in 0 ... members.count-1 {
                if (self.members[i].id == id) {
                    return i
                }
            }
        }
        return -1
    }


    //all user info
    func allUserInfoRequest() {
        
        let subUrl: String = "xe/work/mobile_checklist.php"
        let myUrl: URL = URL(string: urlString + subUrl)!
        
        let request = NSMutableURLRequest(url:myUrl)
        request.httpMethod = "GET"
        
        var isFail: Bool = false
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            guard data != nil else {
                print("error=\(error)");
                return
            }
            
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let resultValue = json["result"] as! String!
                    //print("result: \(resultValue)")
                    
                    if(resultValue != nil && resultValue == "success"){
                        do {
                            if let jsonData = json["data"] as? [[String: AnyObject]]{
                                var index: Int = 0
                                self.members.removeAll()
                                
                                for data in jsonData {
                                    let info = userInfo()
                                    info.id = (data["userid"] as? String)!
                                    info.name = (data["username"] as? String)!
                                    info.telno = (data["telno"] as? String)!
                                    info.department = (data["department"] as? String)!
                                    info.checkValue = (data["checkvalue"] as? String)!
                                    info.checkTime = (data["checkdate"] as? String)!
                                    info.photoUrlPath = (data["profileimage_src"] as? String)!
                                    info.deviceUrlPath = (data["deviceimage_src"] as? String)!
                                    info.playRatio = (data["ratio"] as? Float)!
                                    
                                    if (!info.photoUrlPath.isEmpty && info.photoUrlPath != "-") {
                                        info.photoURL = URL(string: info.photoUrlPath)
                                    } else {
                                        info.photoURL = nil
                                    }
                                    
                                    //목록에 정보가 있으면 갱신, 없으면 추가
                                    let memberIndex = self.existMember(info.id)
                                    if memberIndex >= 0 {
                                        //print("member update : \(info.id) : \(info.name) : \(info.photoUrlPath)")
                                        if (self.members[memberIndex].checkTime != info.checkTime){
                                            info.changed = true
                                        }
                                        self.members[memberIndex] = info
                                    } else {
                                        self.members.insert(info, at: index)
                                    }
                                    index = index + 1
                                }
                            }
                            
                            
                        } catch {
                            print("error: parsing")
                            isFail = true
                        }
                        
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
        };
        task.resume();
    }
}
